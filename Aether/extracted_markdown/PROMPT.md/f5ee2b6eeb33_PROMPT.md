## Assignment: Algebra–MachineLearning–Logic Operadic Tropical VC-Dimension Duality via Neural Semiring Shattering and Canonical Sample Compression

**Mode:** formalize / prove

Aristotle, do not treat this as a modest extension of VC theory. The real target is to build a new algebraic theory of learnability in which **capacity, logical distinguishability, and compression are the same invariant seen through three lenses**. The breakthrough is to replace ad hoc combinatorial capacity bounds by a **canonical quotient theorem** for neural architectures interpreted over idempotent semirings. If successful, this becomes a tropical/operadic analogue of the Myhill–Nerode theorem, but for hypothesis classes rather than languages, and with algorithmic compression as the representation-theoretic shadow of finite distinguishability.

The conceptual slogan is:

> **Finite tropical shattering rank = finite operadic logical quotient = exact bounded sample compression.**

This is the kind of theorem that opens a field, because it would let us certify learnability of structured neural architectures by proving finiteness of an algebraic quotient, not by counting parameters or invoking asymptotic statistical arguments.

---

## Core Formalization Goal

Work in Lean 4 with a new bridge layer around:

- `MachineLearning/OperadicDeepLearning/Foundations.lean`
- a new file such as  
  `MachineLearning/OperadicDeepLearning/TropicalVCDuality.lean`

You should define:

- tropical / idempotent semiring-valued neural evaluation
- semiring-shattering for finite subsets
- tropical VC dimension / rank
- a Myhill–Nerode-style congruence on inputs induced by all realizable layerwise observables up to tropical scalar shift
- finite quotient / representative system
- exact sample compression scheme induced by quotient representatives
- the equivalence implications connecting these notions

The first cycle does **not** need the ultimate strongest theorem in full generality. But it must produce a precise formal scaffold and at least one nontrivial theorem showing a genuine equivalence under explicit hypotheses.

---

## Precise Mathematical Target

Let:

- `X` be an input type,
- `Y = Bool` or `Fin 2` the label space,
- `S` an idempotent semiring (especially tropical min-plus / max-plus),
- `O` a finitely generated `NeuralOperad` whose operations act by tropical affine / residuated layer maps,
- `C : Set (X → Y)` the induced hypothesis class.

Define:

1. **Semiring shattering** of a finite set `A : Finset X`:
   `A` is shattered if every labeling `ℓ : A → Y` is realized by some `h ∈ C`, where realization is witnessed through the operadic tropical evaluation semantics.

2. **Tropical VC rank**:
   \[
   \mathrm{tvc}(C) := \sup\{ |A| : A \subseteq_{\mathrm{fin}} X,\ A\ \text{is semiring-shattered by } C \}.
   \]

3. **Neural operad congruence**:
   `x ≈ y` iff every layerwise tropical evaluation functional in the architecture gives the same value on `x` and `y` up to tropical scalar shift / normalization, equivalently iff `x` and `y` are indistinguishable by all realizable hypotheses in `C`.

4. **Finite quotient property**:
   the quotient `X / ≈` has finite cardinality.

5. **Exact compression scheme of size k**:
   there exists a map sending any finite labeled sample realizable by `C` to a sub-sample of size at most `k` together with finite side information, from which one can reconstruct a classifier agreeing exactly on the original sample.

---

## Theorem Statements to Target

### Theorem A: Finite Quotient Implies Finite Tropical VC Rank and Compression

This is the first major theorem to formalize.

**Informal statement.**  
If the neural operad congruence has finitely many equivalence classes, then the induced hypothesis class has finite tropical VC dimension, bounded by the number of quotient classes, and admits an exact sample compression scheme obtained by retaining one representative from each label-relevant quotient class.

A clean theorem statement is:

\[
\forall C,\ \mathrm{Finite}(X/{\approx_C}) \to \exists k,\ \mathrm{tvc}(C)\le k \land \mathrm{HasCompressionScheme}(C,k).
\]

More sharply, if the quotient has `N` classes, then one can take `k ≤ N`, and often `k` equal to the number of extremal distinguishability classes.

### Lean-style signature sketch

```lean
theorem finite_quotient_implies_finite_tropicalVC_and_compression
  {X S : Type*} [IdempotentSemiring S]
  (O : NeuralOperad S X)
  (C : Set (X → Bool))
  (hC : C = O.hypothesisClass)
  (hfin : Finite (Quotient (NeuralOperadCong O))) :
  ∃ k : ℕ,
    tropicalVCDim C ≤ k ∧
    HasExactCompressionScheme C k
```

A stronger finite-cardinality version:

```lean
theorem tropicalVCDim_le_of_finite_quotient
  {X S : Type*} [IdempotentSemiring S]
  (O : NeuralOperad S X)
  [Fintype (Quotient (NeuralOperadCong O))] :
  tropicalVCDim O.hypothesisClass ≤ Fintype.card (Quotient (NeuralOperadCong O))
```

and then separately:

```lean
theorem hasCompression_of_finite_quotient
  {X S : Type*} [IdempotentSemiring S]
  (O : NeuralOperad S X)
  [Fintype (Quotient (NeuralOperadCong O))] :
  HasExactCompressionScheme
    O.hypothesisClass
    (Fintype.card (Quotient (NeuralOperadCong O)))
```

---

### Theorem B: Finite Tropical VC Rank Implies Finite Separating Family and Quotient
This is the bold direction. It may require stronger hypotheses and should be stated with those hypotheses explicit.

**Informal statement.**  
For finitely generated tropical neural operads of bounded width and finite observable basis, finite tropical VC rank forces the existence of a finite family of tropical linear observables whose joint evaluation separates all realizable dichotomies. Hence the canonical congruence factors through a finite quotient.

This is the difficult converse. It should be stated under hypotheses such as:

- finite generator set for operadic operations,
- bounded layer width,
- each hypothesis determined by a finite support of tropical affine forms,
- normalization by tropical scalar shift,
- definable activation-pattern stratification with finitely many cells per bounded observable family.

A formal target:

```lean
theorem finite_tropicalVC_implies_finite_separating_family
  {X S : Type*} [IdempotentSemiring S]
  (O : NeuralOperad S X)
  (hfg : O.FinitelyGenerated)
  (hwidth : O.BoundedWidth)
  (hobs : O.FiniteObservableBasis)
  (htvc : ∃ k : ℕ, tropicalVCDim O.hypothesisClass ≤ k) :
  ∃ Φ : Finset (TropicalObservable S X),
    SeparatesHypotheses Φ O.hypothesisClass
```

and then

```lean
theorem finite_tropicalVC_implies_finite_quotient
  {X S : Type*} [IdempotentSemiring S]
  [Fintype SObs] -- or a finite observable encoding, depending on design
  (O : NeuralOperad S X)
  (hfg : O.FinitelyGenerated)
  (hwidth : O.BoundedWidth)
  (hobs : O.FiniteObservableBasis)
  (htvc : ∃ k : ℕ, tropicalVCDim O.hypothesisClass ≤ k) :
  Finite (Quotient (NeuralOperadCong O))
```

You may need to weaken this to “there exists a finite-index congruence refining classification equivalence on every finite realizable sample” in the first pass. That is acceptable if stated sharply.

---

### Theorem C: Compression Size Equals Shattering Rank in a Canonical Regime

This is the visionary theorem. It may not be fully provable in cycle one, but the formal definitions should be engineered toward it.

**Informal statement.**  
Under a canonicality / extremal-cell hypothesis, the minimum exact compression size equals the tropical VC rank, and the compression map is obtained by selecting support examples corresponding to extremal cells of the tropical evaluation fan.

A precise target:

```lean
theorem canonical_compression_size_eq_tropicalVCDim
  {X S : Type*} [IdempotentSemiring S]
  (O : NeuralOperad S X)
  (hcan : O.HasCanonicalEvaluationFan)
  (hreg : O.RealizabilityRegular)
  (hfin : ∃ k : ℕ, tropicalVCDim O.hypothesisClass = k) :
  minimalCompressionSize O.hypothesisClass = tropicalVCDim O.hypothesisClass
```

If equality is too ambitious, prove the upper bound by `tropicalVCDim` and isolate the reverse inequality as a conjectural theorem or future theorem.

---

## Key Definitions to Engineer Carefully

### 1. Idempotent Semiring Class
Use an existing Mathlib semiring hierarchy where possible; otherwise define a local class:

```lean
class IdempotentSemiring (S : Type*) extends Semiring S :=
(add_idem : ∀ a : S, a + a = a)
```

You may later specialize to tropical semirings through a dedicated structure.

### 2. Tropical Observables
A tropical observable should encode a layerwise affine/residuated functional:

```lean
structure TropicalObservable (S X : Type*) :=
(eval : X → S)
(respects_shift : Prop)
```

If the semantics naturally produce normalized observables modulo scalar shift, quotient this structure by the relation
`φ ~ ψ ↔ ∃ c, ∀ x, φ x = ψ x + c`
or the appropriate min-plus analogue.

### 3. Classification Equivalence / Congruence
At minimum:

```lean
def NeuralOperadCong {X S : Type*} [IdempotentSemiring S]
  (O : NeuralOperad S X) : Setoid X where
  r x y := ∀ h ∈ O.hypothesisClass, h x = h y
  iseqv := ...
```

Then refine toward layerwise observables-up-to-shift if needed. The classification-equivalence version is easier to prove with first and can later be shown equivalent to the observable congruence under a realization theorem.

### 4. Shattering
For a finite set, use `Finset X`:

```lean
def Shatters (C : Set (X → Bool)) (A : Finset X) : Prop :=
  ∀ ℓ : A → Bool, ∃ h ∈ C, ∀ a : A, h a = ℓ a
```

You may prefer a formulation via functions on the subtype `↑A`.

### 5. Tropical VC Dimension
Because `ℕ∞` or `WithTop ℕ` is natural for infinite classes:

```lean
def tropicalVCDim (C : Set (X → Bool)) : WithTop ℕ :=
  sSup {n : WithTop ℕ | ∃ A : Finset X, A.card = n ∧ Shatters C A}
```

Or define a boundedness predicate first and use the dimension only where finite.

### 6. Compression Scheme
Keep the first formalization simple and exact:

```lean
structure HasExactCompressionScheme (C : Set (X → Bool)) (k : ℕ) : Prop :=
(compress :
  ∀ ⦃A : Finset X⦄, RealizableSample C A →
    ∃ B : Finset X, B ⊆ A ∧ B.card ≤ k × SideInfo)
(reconstruct :
  ∀ ⦃A : Finset X⦄ (hs : RealizableSample C A),
    let data := compress hs
    ∃ h ∈ C, AgreesOnSample h A hs.labels)
```

You may need to parameterize by labeled samples rather than unlabeled `Finset X`.

---

## Proof Strategy Architecture

## Strategy 1: Quotient-First, via Pullback to a Finite Domain
**Most promising for the first formal breakthrough.**

1. Define the canonical equivalence `x ≈ y` by indistinguishability under all hypotheses in `C`.
2. Show every `h ∈ C` factors through the quotient map `π : X → X/≈`.
3. If the quotient is finite of size `N`, then every shattered set injects into the quotient, hence has size at most `N`. Therefore `tropicalVCDim(C) ≤ N`.
4. Construct compression by retaining one representative from each quotient class appearing in the sample, plus labels. Reconstruction is by selecting any classifier in `C` consistent with the compressed data; exactness follows because hypotheses are constant on quotient classes.

Why this is promising: it uses only finite quotient combinatorics and avoids the deepest tropical geometry at first. It gives a robust theorem with immediate formal traction in Lean.

---

## Strategy 2: Observable-Fan Geometry, via Tropical Cell Decomposition
**Most revolutionary if the infrastructure supports it.**

1. Model each hypothesis as determined by a finite set of tropical affine observables.
2. Show the input space is partitioned into cells of an evaluation fan where activation/comparison patterns are constant.
3. Prove that realizable dichotomies depend only on cell membership or extremal cell data.
4. Compression is obtained by selecting one witness per extremal cell needed to reconstruct the labeling pattern.
5. Finite shattering rank is then equivalent to bounded number of relevant fan cells.

Why this matters: this turns VC/sample compression into tropical polyhedral geometry. It opens direct connections to Newton polytopes, regular subdivisions, and tropical hyperplane arrangements.

Risk: substantial formal overhead unless existing tropical infrastructure is already present.

---

## Strategy 3: Logical Definability and Myhill–Nerode Analogy
**Best for the converse direction.**

1. Regard each hypothesis as a unary predicate definable by a bounded operadic term in the semiring language.
2. Define a syntactic indistinguishability relation: two inputs are equivalent if all formulas / observables from a bounded fragment agree.
3. Show finite tropical VC rank implies a finite basis of distinguishers under finite-generation and bounded-width hypotheses.
4. Deduce a finite quotient, analogous to finite-index right congruence in Myhill–Nerode.

Why this is profound: it reframes learnability as finite model-theoretic complexity. This could seed a new “logical learning theory” for tropical neural architectures.

Risk: requires careful bounded-fragment formalization and may need a weaker first theorem.

---

## Recommended Execution Order

1. **Formalize the classification congruence** `NeuralOperadCong`.
2. **Prove factorization of hypotheses through the quotient.**
3. **Prove finite quotient ⇒ finite tropical VC dimension.**
4. **Build exact compression from quotient representatives.**
5. Add a more semantic observable congruence and prove it refines / coincides with classification congruence under realizability assumptions.
6. State the converse theorem with hypotheses, prove a weak finite-separating-family version if full quotient finiteness is not yet reachable.
7. Introduce extremal-cell compression only after the finite quotient theorem is in place.

---

## Lean 4 Type Signature Suggestions

These are sketches, not mandatory final APIs.

```lean
class NeuralOperad (S X : Type*) where
  hypothesisClass : Set (X → Bool)
  -- later: generators, layers, composition, observables, width bounds, etc.
```

```lean
def ClassificationCong {X : Type*} (C : Set (X → Bool)) : Setoid X where
  r x y := ∀ h, h ∈ C → h x = h y
  iseqv := by
    refine ⟨?refl, ?symm, ?trans⟩
```

```lean
theorem hypothesis_factors_through_quotient
  {X : Type*} {C : Set (X → Bool)} (h : X → Bool) (hh : h ∈ C) :
  ∃ g : Quotient (ClassificationCong C) → Bool,
    h = g ∘ Quotient.mk''
```

```lean
def Shatters {X : Type*} (C : Set (X → Bool)) (A : Finset X) : Prop := ...
```

```lean
def tropicalVCDim {X : Type*} (C : Set (X → Bool)) : WithTop ℕ := ...
```

```lean
theorem card_le_card_quotient_of_shattered
  {X : Type*} {C : Set (X → Bool)} [Fintype (Quotient (ClassificationCong C))]
  {A : Finset X} (hA : Shatters C A) :
  A.card ≤ Fintype.card (Quotient (ClassificationCong C))
```

```lean
theorem finite_quotient_implies_finite_VC
  {X : Type*} {C : Set (X → Bool)}
  [Fintype (Quotient (ClassificationCong C))] :
  tropicalVCDim C ≤ Fintype.card (Quotient (ClassificationCong C))
```

```lean
structure LabeledSample (X : Type*) where
  pts : Finset X
  lab : {x // x ∈ pts} → Bool
```

```lean
structure HasExactCompressionScheme {X : Type*}
  (C : Set (X → Bool)) (k : ℕ) : Prop where
  compress :
    LabeledSample X → Option (Finset X × Finset Bool) -- replace with better side info
  sound :
    ...
```

For the semiring-sensitive layer, later define:

```lean
structure TropicalAffineMap (S X Y : Type*) :=
(eval : X → Y) -- placeholder for actual affine data
```

```lean
structure TropicalNeuralLayer (S X Y : Type*) :=
(map : X → Y)
(is_residuated : Prop)
```

and then connect the generated hypothesis class to the abstract `Set (X → Bool)` interface.

---

## Cross-Domain Connections You Should Explicitly Exploit

### 1. Automata Theory / Logic
This is a neural Myhill–Nerode theorem. In automata theory, finite-index congruence characterizes regularity. Here, finite-index **input distinguishability congruence** should characterize a learnability/compression regime. The analogy is not cosmetic; it should shape the formal statement and proof structure.

### 2. Tropical Geometry
The “observable up to scalar shift” relation is inherently tropical projective geometry. Compression by extremal cells is the learning-theoretic avatar of selecting generators of a tropical polyhedral complex. If formalized, this would link sample compression to tropical convexity and cell decomposition.

### 3. Universal Algebra / Operads
Finitely generated neural operads are not just implementation artifacts. They give the algebraic mechanism by which local layerwise compositions produce global hypothesis classes. The finite quotient theorem should be phrased operadically: finite generator complexity induces finite observable semantics under bounded shattering.

### 4. Statistical Learning Theory
Classical VC dimension is combinatorial. Your theorem would explain it as a quotient cardinality phenomenon in an idempotent algebraic semantics. This could yield certifiable compression and architecture selection criteria unavailable to parameter-count methods.

### 5. Model Theory / Definability
Finite shattering rank often signals NIP-like tameness. There may be a tropical-definable analogue: bounded semiring shattering forcing finite definability rank. Even if not proved now, structure the definitions so this bridge is possible.

### 6. Category Theory / Semantics
A quotient universal property should emerge: the classifier semantics factors through the coarsest congruence preserving all realizable outputs. This makes the theorem a semantic minimality result, not just a combinatorial bound.

---

## Why This Would Be a Breakthrough

If you prove even the forward half cleanly in Lean, you establish a **new algebraic certificate of learnability**:

- not “this class has small VC dimension because of a counting argument,” but
- “this architecture is learnable because its semantics factors through a finite canonical quotient.”

That is a different worldview.

If you also obtain a converse under finite-generation hypotheses, you create a field-opening triad:

1. **Logical finiteness:** finite-index neural congruence  
2. **Combinatorial finiteness:** finite tropical VC rank  
3. **Algorithmic finiteness:** bounded exact compression

This would make operadic/tropical deep learning mathematically analyzable with tools from automata, tropical geometry, and universal algebra in a unified framework. It suggests new certification pipelines for architecture compression, interpretability, and learnability.

---

## Concrete Formal Milestones

1. Define `ClassificationCong` and prove it is a `Setoid`.
2. Prove every hypothesis factors through the quotient.
3. Prove shattered sets inject into the quotient.
4. Deduce finite quotient bounds `tropicalVCDim`.
5. Define an exact compression scheme from quotient representatives.
6. Refine to `NeuralOperadCong` based on layerwise tropical observables up to scalar shift.
7. Prove classification equivalence follows from observable equivalence.
8. State and, if possible, partially prove the converse under finite-generation/bounded-width assumptions.
9. Introduce tropical evaluation fan and extremal-cell compression if infrastructure permits.

---

## Application Keywords

tropical learning theory; operadic deep learning; idempotent semirings; sample compression; VC dimension; Myhill–Nerode for hypothesis classes; neural congruence; tropical affine geometry; residuated algebra; finite quotient semantics; logical learnability; tropical polyhedral fans; exact compression certificates; architecture minimization; algebraic capacity control

---

## Deliverables

1. Lean file(s) with the core definitions and at least one substantial theorem:
   preferably `finite_quotient_implies_finite_tropicalVC_and_compression`.
2. Theorems stated with explicit hypotheses, even if some converse proofs remain partial.
3. Documentation comments explaining the automata/tropical analogy.
4. A structured `FUTURE_DIRECTIONS.md` containing **3–5 concrete, breakthrough-level next steps**, such as:
   - proving the converse via finite observable bases,
   - formalizing tropical evaluation fans and extremal-cell compression,
   - extending from binary classification to semiring-valued multiclass decision rules,
   - relating tropical VC rank to NIP-style definability invariants,
   - deriving certified architecture minimization algorithms from quotient minimization.

Be bold: the right result here is not another VC bound. It is a new theorem schema saying that **learnability is quotient finiteness in disguise**.

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
    "algorithms": [ { "name": "...", "pseudocode": "..." } ],
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
Research mode: formalize
