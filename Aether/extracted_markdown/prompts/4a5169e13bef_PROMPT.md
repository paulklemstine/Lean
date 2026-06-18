## Assignment: Algebra–Tropical–Logic — Tropical Stone Duality via Idempotent Heyting Semimodules and Certified Kripke Frame Reconstruction

**Mode:** `prove`

Aristotle, this is not a variant project. This is the founding document for a new bridge: **tropical algebraic logic as a reconstructive duality theory**. The aim is to create the first finite Stone/Priestley-style duality in which the algebraic side is not a lattice or Boolean/Heyting algebra, but an **idempotent semimodule with residuation**, and the semantic side is not merely a poset, but a **certifiably reconstructed finite Kripke frame** extracted from tropical valuation data.

The conceptual leap is this:

- classical Stone duality: syntax/algebra ↔ space of points,
- Priestley/Esakia duality: Heyting algebra ↔ ordered topological semantics,
- your target here: **idempotent tropical semimodule with implication ↔ finite preorder/Kripke frame reconstructed from tropical prime points**.

If this lands cleanly in Lean, it opens a new field: **tropical proof semantics**, where semantic frames can be recovered from optimization-style algebraic invariants.

---

## Core theorem package

Create:

`Bridges/TropicalStoneDuality.lean`

and formalize the full pipeline:
- algebraic object `IdempotentHeytingSemimodule`
- point object `TropicalPrimeFilter` or `TropicalPoint`
- finite spectrum `PrimeSpectrum`
- specialization/canonical order on points
- frame reconstruction
- upset/valuation semimodule of the frame
- representation and reconstruction theorems
- algorithmic certification lemmas for finite reconstruction

Minimize `sorry`. If necessary, isolate finite combinatorial lemmas into helper files.

---

## Mathematical target

Let `M` be a finitely generated idempotent semimodule over an idempotent semiring `R`, equipped with:
- a canonical order `a ≤ b :↔ a ⊔ b = b`,
- finite joins / meets where needed,
- an internal implication `imp : M → M → M`,
- residuation:
  \[
  x \otimes a \le b \iff x \le (a \Rightarrow b),
  \]
  or, if internal scalar/tensor notation is not yet canonical in Mathlib form, an order-theoretic adjunction sufficient to define a Heyting-style implication.

Define a class of **tropical prime points** `p : M → T` into a finite tropical truth object `T` (preferably a two-level object for the first pass, though a min-plus truth codomain is a powerful second stage) such that:
- `p` preserves finite joins,
- `p` preserves top/bottom if present,
- `p` is implication-compatible,
- primeness/separation is strong enough that distinct elements of `M` are distinguished by some point.

Then prove that the finite spectrum of such points determines a canonical preorder, and that `M` embeds into the semimodule of upset-valuations on that preorder. Under a finite generation + separation + closure hypothesis, this embedding is an isomorphism.

---

## Precise theorem statements

### 1. Evaluation injectivity from point separation

**Informal theorem.**  
If tropical prime points separate elements of `M`, then the evaluation map from `M` to functions on the prime spectrum is injective.

**Lean target signature sketch**
```lean
theorem evaluation_injective_of_separating
  {R M T Ω : Type*}
  [Finite Ω]
  [IdempotentHeytingSemimodule R M]
  [TropicalTruthObject T]
  (Spec : Type*) [Fintype Spec]
  (eval : M → Spec → T)
  (hsep : ∀ {a b : M}, a ≠ b → ∃ p : Spec, eval a p ≠ eval b p) :
  Function.Injective (fun a : M => fun p : Spec => eval a p)
```

A more structural version is preferred:
```lean
theorem evaluation_injective_of_separating
  {R M T : Type*}
  [IdempotentHeytingSemimodule R M]
  [TropicalTruthObject T]
  [Fintype (PrimeSpectrum M T)]
  (hsep : PairwiseSeparatedByPoints (M := M) (T := T)) :
  Function.Injective (evaluationMap (M := M) (T := T))
```

This is the gateway lemma. Everything else rides on it.

---

### 2. Finite tropical representation theorem

**Informal theorem.**  
A finitely generated point-separating idempotent Heyting semimodule is isomorphic to a semimodule of tropical valuations on its prime spectrum, with operations computed pointwise.

**Lean target signature sketch**
```lean
theorem representation_iso_of_finite_separating
  {R M T : Type*}
  [IdempotentHeytingSemimodule R M]
  [TropicalTruthObject T]
  [Fintype (PrimeSpectrum M T)]
  [FiniteGeneration R M]
  (hsep : PairwiseSeparatedByPoints (M := M) (T := T))
  (hclosed : EvaluationImageClosedUnderOps (M := M) (T := T)) :
  Nonempty ((M ≃ₗ[R] TropicalValuationSubsemimodule (PrimeSpectrum M T) T))
```

If linear equivalence is too strong initially because implication is extra structure, use:
```lean
Nonempty (M ≃o TropicalValuationSubstructure (PrimeSpectrum M T) T)
```
or a bundled structure isomorphism preserving `sup`, scalar action, and `imp`.

A stronger endpoint:
```lean
theorem representation_as_upset_semimodule
  {R M T : Type*}
  [FiniteIdempotentHeytingSemimodule R M]
  [TropicalTruthObject T]
  (hsep : PairwiseSeparatedByPoints (M := M) (T := T)) :
  Nonempty (M ≃ₕ TropicalUpsetSemimodule (canonicalPreorder (PrimeSpectrum M T)) T)
```
where `≃ₕ` is your custom structure isomorphism preserving implication.

---

### 3. Canonical preorder reconstruction theorem

**Informal theorem.**  
The specialization order on tropical prime points reconstructed from valuation domination is the unique finite preorder whose upset semimodule recovers the original algebra.

Define:
\[
p \preceq q \quad:\!\!\iff\quad \forall a \in M,\; p(a) \le q(a)
\]
or the orientation that matches upset semantics after testing.

**Lean target signature sketch**
```lean
def canonicalPreorder
  {R M T : Type*}
  [IdempotentHeytingSemimodule R M]
  [Preorder T] :
  Preorder (PrimeSpectrum M T)
```

Then prove:
```lean
theorem frame_reconstruction_correct
  {R M T : Type*}
  [FiniteIdempotentHeytingSemimodule R M]
  [TropicalTruthObject T]
  (hsep : PairwiseSeparatedByPoints (M := M) (T := T))
  (hclosed : EvaluationImageClosedUnderOps (M := M) (T := T)) :
  Nonempty (
    M ≃ₕ upsetSemimodule (frameOfSpectrum (PrimeSpectrum M T) (canonicalPreorder (M := M) (T := T))) T
  )
```

And the uniqueness theorem:
```lean
theorem canonical_frame_unique
  {R M T : Type*}
  [FiniteIdempotentHeytingSemimodule R M]
  [TropicalTruthObject T]
  (F : FiniteKripkeFrame)
  (hrepr : Nonempty (M ≃ₕ upsetSemimodule F T)) :
  FrameEquivalent F (frameOfSpectrum (PrimeSpectrum M T) (canonicalPreorder (M := M) (T := T)))
```

This is the actual Stone duality statement in finite form.

---

### 4. Certified algorithmic reconstruction theorem

**Informal theorem.**  
For finite `M`, one can compute the frame order from the prime spectrum by exhaustive comparison of valuations, and this computed relation equals the semantic preorder.

**Lean target signature sketch**
```lean
def computeCanonicalOrder
  {R M T : Type*}
  [FiniteIdempotentHeytingSemimodule R M]
  [DecidableEq (PrimeSpectrum M T)]
  [Fintype (PrimeSpectrum M T)]
  [DecidableEq M]
  [Fintype M]
  [Preorder T] [DecidableRel ((· ≤ ·) : T → T → Prop)] :
  PrimeSpectrum M T → PrimeSpectrum M T → Bool
```

Correctness theorem:
```lean
theorem computeCanonicalOrder_spec
  {R M T : Type*}
  [FiniteIdempotentHeytingSemimodule R M]
  [DecidableEq (PrimeSpectrum M T)]
  [Fintype (PrimeSpectrum M T)]
  [DecidableEq M]
  [Fintype M]
  [Preorder T] [DecidableRel ((· ≤ ·) : T → T → Prop)] :
  ∀ p q : PrimeSpectrum M T,
    computeCanonicalOrder (M := M) (T := T) p q = true
      ↔ canonicalPreorder (M := M) (T := T) p q
```

And if you define accessibility/implication tables:
```lean
theorem implication_table_reconstruction_correct
  {R M T : Type*}
  [FiniteIdempotentHeytingSemimodule R M]
  [TropicalTruthObject T]
  ... :
  reconstructedImpTable (M := M) (T := T) =
    semanticImpTable (frameOfSpectrum ...)
```

This turns the duality into a certified extraction pipeline.

---

## Structure design suggestions

You likely need a custom bundled structure because existing Mathlib classes will only partially overlap.

### Proposed core structure
```lean
class IdempotentHeytingSemimodule (R M : Type*) extends Semiring R, AddCommMonoid M, Module R M :=
  (sup : M → M → M)
  (inf : M → M → M)
  (top : M)
  (bot : M)
  (imp : M → M → M)
  (le : M → M → Prop)
  (le_def : ∀ a b, le a b ↔ sup a b = b)
  (imp_adj : ∀ x a b, le (smul x a) b ↔ le x (imp a b))
  ...
```

But this may be too heavy. A more Lean-native route is better:

- use existing `SemilatticeSup`, `SemilatticeInf`, `OrderBot`, `OrderTop`, `Preorder`
- require an idempotent scalar semiring separately
- define implication as a field with adjunction law
- if `Module` is too rigid for idempotent semiring use, define a custom scalar action structure

A practical first pass:
```lean
class IdempotentHeytingSemimodule (R M : Type*) :=
  [instSemiring : Semiring R]
  [instSup : Sup M]
  [instInf : Inf M]
  [instTop : Top M]
  [instBot : Bot M]
  [instPreorder : Preorder M]
  (smul : R → M → M)
  (imp : M → M → M)
  (sup_eq_lub : ...)
  (imp_residuation : ∀ x a b, smul x a ≤ b ↔ x ≤ imp a b)
  ...
```

You may later refine to a better typeclass hierarchy once the theorem spine is proven.

---

## Prime points / filters

There are two equivalent routes. Choose one and prove equivalence later if feasible.

### Route A: points as morphisms into a truth object
Define:
```lean
structure TropicalPoint (M T : Type*) :=
  (toFun : M → T)
  (map_sup' : ...)
  (map_imp' : ...)
  (prime' : ...)
```

This is more Stone-like and directly supports evaluation.

### Route B: prime filters as subsets
Define:
```lean
structure TropicalPrimeFilter (M : Type*) :=
  (carrier : Set M)
  (upward_closed' : ...)
  (meet_closed' : ...)
  (prime_sup' : ...)
  (imp_stable' : ...)
```

Then derive points into `Prop`-like or two-valued tropical truth.

**Recommendation:** start with **points as morphisms**, because evaluation and finite function-space representation become much easier. Then define filters as fibers/preimages if needed.

---

## Proof strategies

## Strategy A: Stone-style evaluation embedding via finite point separation
This is the most promising route.

1. **Define the spectrum as a finite family of implication-preserving point morphisms.**  
   Use the pointwise semimodule/order structure on `Spec → T`.

2. **Construct the evaluation map**  
   \[
   \mathrm{ev}(a)(p)=p(a).
   \]
   Prove it preserves the algebraic operations pointwise.

3. **Injectivity from separation.**  
   This is immediate once points separate elements.

4. **Identify the image as a closed substructure** under finite joins/meets/implication.  
   This gives a representation theorem as a subalgebra/subsemimodule of functions on the spectrum.

5. **Promote from substructure to upset semimodule** by characterizing which functions arise as admissible valuations on the canonical order.

Why this is strongest: it mirrors certified Stone/Priestley arguments and keeps the semantics explicit at every stage. It is also the most Lean-friendly because function extensionality and finite pointwise algebra are robust.

---

## Strategy B: Birkhoff-style finite reconstruction from join-prime generators
This is more algebraic and may reduce the semantic overhead.

1. Use finite generation to obtain a finite generating set and define a notion of **join-prime / implication-prime** element.
2. Build a finite preorder on these generators by algebraic domination.
3. Show every element of `M` corresponds to an upset of this preorder, with implication realized as the Heyting implication of upsets.
4. Identify points with principal or prime-generated evaluations and show equivalence with the spectrum construction.

Why it may help: if the notion of tropical prime point becomes technically awkward, this route may provide a purely finite combinatorial skeleton from which the spectrum is derived afterward.

Risk: more bespoke finite lattice/semimodule combinatorics.

---

## Strategy C: Priestley/Esakia adaptation through order-enriched spectra
This is the most conceptually ambitious.

1. Treat the spectrum as an ordered space with specialization order defined by valuation domination.
2. Show evaluation lands in monotone/upset-valued functions.
3. Prove an Esakia-style correspondence between implication and upward-closed relational semantics.
4. Specialize to finite spaces to avoid topology and recover the frame.

Why this matters: it is the route to the strongest future generalization, beyond finite frames into ordered tropical spaces.  
Why it is second-stage: topology in Lean will add complexity not needed for the finite breakthrough.

---

## Most promising execution plan

Start with **Strategy A**, then import one key insight from Strategy C: the **canonical preorder on points by valuation domination**. This gives the finite duality in a clean two-step architecture:

1. **Algebra → function representation on points**  
2. **Function representation → upset semantics on the canonical preorder**

That decomposition is mathematically elegant and formally manageable.

---

## Building on catalog / likely reusable infrastructure

You should explicitly mine Mathlib and local catalog infrastructure for:

- finite function extensionality lemmas,
- `Fintype`-based exhaustive decision procedures,
- order structures on function spaces,
- subsemiring/submodule/subobject closure patterns,
- Galois connection / residuation lemmas if available,
- finite poset/upset/set-like constructions,
- equivalences between monotone predicates and upsets on finite preorders.

If the catalog contains any certified tropical robustness or residuation results, use them as **proof pattern templates**, not merely inspiration:
- any theorem proving a tropical object is determined by evaluations on a finite witness family is directly analogous to `evaluation_injective_of_separating`;
- any theorem extracting combinatorial certificates from tropical inequalities should inform the reconstruction algorithm;
- any existing order-theoretic tropical duality or spectrum formalization should be repurposed for your `canonicalPreorder`.

In particular, look for:
- certified finite reconstruction patterns,
- separation-by-functionals lemmas,
- substructure closure under pointwise operations,
- order reconstruction from evaluations.

---

## Cross-domain connections you should explicitly exploit

### 1. Logic × Tropical geometry
The spectrum of tropical points is a **tropicalized semantic space**. This is not just logic over semirings; it is a geometric semantics where truth values behave like piecewise-linear valuation data. The canonical preorder is the logical analogue of specialization order in tropical geometry.

### 2. Stone/Priestley duality × idempotent analysis
Classical duality theory is usually additive/lattice-theoretic; idempotent analysis studies max-plus/min-plus linearity. Your theorem says these worlds are secretly the same at finite scale when implication/residuation is added.

### 3. Kripke semantics × optimization
Reconstructing a frame from valuation domination is a semantic version of **recovering latent order from cost profiles**. This suggests applications to:
- abstract interpretation,
- shortest-path style semantics,
- proof compression by valuation signatures,
- semantic compilation of logical systems into tropical linear objects.

### 4. Neurosymbolic verification × certified model extraction
A proof object in an idempotent semimodule could be turned into a finite semantic model automatically. That is exactly the kind of bridge needed for certified extraction of symbolic structure from learned or optimization-derived systems.

### 5. Domain theory × program semantics
The canonical preorder on points is a finite observational preorder. This aligns with domain-theoretic semantics and could make tropical semimodules a new denotational language for resource-sensitive or cost-aware intuitionistic computation.

---

## Why this is a breakthrough

Because it upgrades tropical logic from “a semantics one can define” to “a semantics one can **reconstruct canonically from algebraic data**.” That is a field-defining move.

If successful, this theorem becomes the seed of:

- **tropical Esakia duality**,
- **tropical modal duality**,
- **certified frame extraction from proof algebras**,
- **semantic compression of optimization-derived logical systems**,
- and eventually **algorithmic duality compilers** turning algebraic certificates into executable semantic models.

This is not another semantics paper. It is a new representation theory for logic in the idempotent world.

---

## Concrete implementation milestones

1. Define `TropicalTruthObject`.
   - Start with a two-element ordered object if necessary.
   - Generalize later to finite min-plus truth values.

2. Define `IdempotentHeytingSemimodule`.
   - Keep the axioms minimal but enough for pointwise function-space closure.

3. Define `TropicalPoint` and `PrimeSpectrum`.
   - Make the spectrum finite when `M` is finite/finitely generated under your assumptions.

4. Define `evaluationMap`.
   - Prove operation preservation.
   - Prove injectivity from separation.

5. Define `canonicalPreorder`.
   - Prove reflexive/transitive.
   - Prove evaluation functions are monotone/upset-compatible.

6. Define `upsetSemimodule`.
   - Show image of evaluation lands there.

7. Prove representation isomorphism.
   - First as substructure of all functions.
   - Then identify with upset semimodule.

8. Define `computeCanonicalOrder`.
   - Prove boolean correctness theorem.
   - If feasible, extract implication/accessibility tables.

---

## Lean file theorem list

Target theorem names:

```lean
evaluation_injective_of_separating
evaluationMap_preserves_sup
evaluationMap_preserves_imp
canonicalPreorder_def
canonicalPreorder_isPreorder
evaluation_monotone_on_canonicalPreorder
evaluation_image_closed_under_sup
evaluation_image_closed_under_inf
evaluation_image_closed_under_imp
representation_substructure_of_finite_separating
representation_as_upset_semimodule
frame_reconstruction_correct
canonical_frame_unique
computeCanonicalOrder_spec
reconstruct_frame_correct
```

Definitions to include:

```lean
IdempotentHeytingSemimodule
TropicalTruthObject
TropicalPoint
PrimeSpectrum
evaluationMap
canonicalPreorder
frameOfSpectrum
upsetSemimodule
computeCanonicalOrder
reconstructedImpTable
```

---

## Ambitious extension if the core theorem lands early

After proving the two-valued finite theorem, attempt the min-plus refinement:

- replace `T` by a finite tropical chain,
- define points preserving tropical finite joins and implication,
- show the canonical preorder becomes a **weighted** or enriched frame,
- derive a weighted Kripke semantics.

That would elevate the result from tropical Stone duality to **quantitative tropical duality**.

---

## Deliverables

1. `Bridges/TropicalStoneDuality.lean` with the full finite duality pipeline.
2. If needed, helper files for finite upsets / pointwise implication structures.
3. A concise note in comments stating which assumptions are essential and which are artifacts of the current formalization.
4. A structured `FUTURE_DIRECTIONS.md` containing **3–5 concrete breakthrough next steps**, for example:
   - tropical Esakia duality for finite modal/intuitionistic algebras,
   - weighted/enriched spectra over min-plus truth objects,
   - algorithmic extraction of countermodels from residuated semimodule proofs,
   - tropical bisimulation and semantic minimization,
   - categorical duality between finite tropical frames and finitely presented idempotent Heyting semimodules.

---

## Application keywords

**tropical Stone duality, Priestley duality, Esakia duality, idempotent semimodules, residuation, Heyting implication, Kripke frame reconstruction, finite model extraction, certified semantics, tropical logic compilation, algebraic proof objects, optimization semantics, domain theory, abstract interpretation, neurosymbolic verification, semantic compression, idempotent analysis, ordered spectra, tropical representation theory**

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
