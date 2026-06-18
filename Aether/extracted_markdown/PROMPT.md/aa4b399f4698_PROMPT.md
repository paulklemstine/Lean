## Assignment: 5. Theorem Embeddings from Syntax: Automatic TheorySpec Extraction

**Mode:** `prove` + `formalize`

Prove a genuinely new theorem about the *automatic extraction of semantic lower-bound specifications from theorem syntax*, and formalize the extraction pipeline in Lean 4 so that verified bridge theorems can be converted into reusable `TheorySpec` objects with minimal human intervention.

This is not mere automation plumbing. If successful, it creates a **semantic compiler from theorem statements to machine-actionable mathematical theories**. That is a new layer of formal mathematics: theorems become data, bridges become searchable, and cross-domain transfer becomes algorithmic rather than manual.

---

## Breakthrough Objective

The central claim is that a substantial class of existing bridge theorems in the catalog already *are* `TheorySpec`s in disguise. Their syntax contains enough structure to recover:

- a carrier type `α`,
- a witness predicate `Witness : α → Prop`,
- an invariant/measurement function `inv : α → ℕ` or another ordered codomain,
- a constant lower bound `lowerBound`,
- and a soundness theorem `∀ x, Witness x → lowerBound ≤ inv x`.

The breakthrough is to **prove correctness of a syntactic extractor** for theorem statements of this form, and then instantiate it on existing catalog theorems such as:

- `depth_lower_bound_from_obstruction`
- `purity_lower_bound_from_spectrum`
- `sample_lower_bound_from_shattering`
- `witness_lower_bound_on_variation`

The long-range vision is a self-indexing theorem ecosystem in which formal statements are automatically lifted into a graph of reusable principles.

---

## Precise Theorem Target

You should define a syntactic recognition predicate for theorem expressions and prove that, whenever a theorem type matches the lower-bound schema, the extracted data yields a valid `TheorySpec`.

Because the exact existing `TheorySpec` structure is not provided here, I recommend introducing a canonical version if needed:

```lean
structure TheorySpec where
  α : Type
  Witness : α → Prop
  inv : α → ℕ
  lowerBound : ℕ
  sound : ∀ x, Witness x → lowerBound ≤ inv x
```

Then formalize a syntactic recognizer over theorem *types*.

### Core semantic theorem

A strong target is:

```lean
/-- `MatchesLowerBoundSchema ty` means that `ty` is definitionally/syntactically
equivalent to a theorem of the form `∀ x : α, P x → n ≤ f x`. -/
def MatchesLowerBoundSchema (ty : Expr) : Prop := ...

/-- Extracts the components of a lower-bound theorem statement when possible. -/
structure ExtractedLowerBound where
  α : Expr
  pred : Expr
  bound : Expr
  fn : Expr

def extractLowerBound? (ty : Expr) : MetaM (Option ExtractedLowerBound) := ...

/-- Soundness of extraction at the semantic level: if a theorem statement is
recognized and a proof term inhabits it, then one obtains a `TheorySpec`. -/
theorem extraction_sound
    (α : Type) (P : α → Prop) (f : α → ℕ) (n : ℕ)
    (h : ∀ x : α, P x → n ≤ f x) :
    ∃ T : TheorySpec,
      T.α = α ∧
      T.Witness = P ∧
      T.inv = f ∧
      T.lowerBound = n := by
  ...
```

This theorem is mathematically clean and should be easy to prove. But it is only the first layer.

### Stronger metaprogramming-correctness theorem

The more ambitious theorem, and the one that would be genuinely field-opening, is:

```lean
/-- If the extractor succeeds on the quoted theorem type `ty`,
then the extracted fields reify a valid lower-bound schema. -/
theorem extractLowerBound?_correct
    (ty : Expr) (res : ExtractedLowerBound)
    (hres : extractLowerBound? ty = pure (some res)) :
    MatchesLowerBoundSchema ty := by
  ...
```

and then a bridge from syntax to semantics:

```lean
/-- Given a theorem proof whose type is recognized by the extractor,
we can build a semantic `TheorySpec`. -/
theorem extracted_expr_yields_theorySpec
    (α : Type) (P : α → Prop) (f : α → ℕ) (n : ℕ)
    (thm : ∀ x : α, P x → n ≤ f x) :
    Nonempty TheorySpec := by
  refine ⟨{
    α := α
    Witness := P
    inv := f
    lowerBound := n
    sound := thm
  }⟩
```

### Lean 4 type signature for the practical API

The API Aristotle should aim to expose:

```lean
def mkTheorySpecOfLowerBoundTheorem
    (α : Type) (P : α → Prop) (f : α → ℕ) (n : ℕ)
    (h : ∀ x : α, P x → n ≤ f x) :
    TheorySpec
```

with implementation:

```lean
def mkTheorySpecOfLowerBoundTheorem
    (α : Type) (P : α → Prop) (f : α → ℕ) (n : ℕ)
    (h : ∀ x : α, P x → n ≤ f x) :
    TheorySpec :=
{
  α := α
  Witness := P
  inv := f
  lowerBound := n
  sound := h
}
```

Then, for catalog theorems, instantiate this constructor directly. For example, if
`sample_lower_bound_from_shattering` has type of the form

```lean
∀ x : α, Shatters x → n ≤ sampleComplexity x
```

then target a theorem like:

```lean
def sample_lower_bound_from_shattering_spec : TheorySpec := ...
```

The crucial novelty is not this constructor alone, but the theorem that **syntactic recognition can discover such instances automatically**.

---

## Concrete Theorems to Prove

### Theorem A: Canonical semantic packaging theorem
This is the foundational theorem and should definitely be formalized.

```lean
theorem exists_theorySpec_of_lower_bound_theorem
    (α : Type) (P : α → Prop) (f : α → ℕ) (n : ℕ)
    (h : ∀ x : α, P x → n ≤ f x) :
    ∃ T : TheorySpec,
      T.α = α ∧
      T.Witness = P ∧
      T.inv = f ∧
      T.lowerBound = n ∧
      T.sound = h := by
  ...
```

If extensional equality on functions causes trouble, weaken the last conjunct to
`T.sound x hx = h x hx` pointwise, or omit equality of fields and instead prove the exact values by `rfl` after constructing `T`.

### Theorem B: Catalog lifting theorem
For each existing theorem in the catalog that has the required shape, produce an explicit `TheorySpec` object and prove its soundness.

Illustrative target:

```lean
def depth_lower_bound_from_obstruction_spec : TheorySpec := ...
def purity_lower_bound_from_spectrum_spec (k : ℕ) (hk : k > 0) : TheorySpec := ...
def sample_lower_bound_from_shattering_spec {α : Type*} : TheorySpec := ...
def witness_lower_bound_on_variation_spec : TheorySpec := ...
```

and then prove a registry theorem:

```lean
theorem bridge_theorem_embeds_as_theorySpec :
    Nonempty TheorySpec := by
  ...
```

Better still, construct a list or sigma-type of extracted specs from the catalog.

### Theorem C: Syntactic completeness for a normalized fragment
Define a normalized syntax fragment of theorem types and prove that your extractor is complete for it.

For example:

```lean
inductive LowerBoundShape where
  | mk (α : Type) (P : α → Prop) (f : α → ℕ) (n : ℕ)

theorem extractor_complete_on_normalized_lower_bounds
    (α : Type) (P : α → Prop) (f : α → ℕ) (n : ℕ) :
    ∃ res,
      extractLowerBound? (← `(∀ x : $α, $P x → $n ≤ $f x)) = pure (some res) := by
  ...
```

If quotation at that level is too difficult, prove a simpler theorem about the decomposition logic over `Expr.forallE` / implication / application trees. That still counts as a mathematically meaningful metatheorem.

---

## Why This Is a Breakthrough

This opens a new area: **formal theorem mining**. Not theorem proving in the usual sense, but theorem *semantic extraction* from verified corpora.

If you succeed, the consequences are substantial:

1. **Automated bridge graph construction**  
   Existing theorems become nodes with extracted invariants, predicates, and lower bounds. This allows search and transfer across domains.

2. **Machine-guided conjecture formation**  
   Once lower-bound theorems are uniformly represented, one can compare witness predicates and invariants across topology, learning theory, spectral theory, tropical geometry, and quantum algebra.

3. **Verified mathematical knowledge extraction**  
   This is the formal analogue of information extraction in NLP, except here the source language is dependent type theory and the output is semantically certified.

4. **A foundation for theorem embeddings and retrieval**  
   The title “Theorem Embeddings from Syntax” becomes literal: syntax is embedded into a semantic object space of theory specifications.

This is the kind of result that could define an entire research program in Lean-native mathematical AI.

---

## Proof Strategy Options

### Strategy A: Semantic-first, syntax-second
This is the most promising route.

1. **Define a minimal `TheorySpec` and prove the canonical constructor theorem**  
   First prove that any theorem of the form `∀ x, P x → n ≤ f x` canonically yields a `TheorySpec`.

2. **Normalize a fragment of theorem syntax**  
   Write helper functions that peel off:
   - one outer `forall`,
   - one implication,
   - one inequality `LE.le`,
   - and detect whether the lower side is a closed constant and the upper side is an application `f x`.

3. **Prove soundness of the recognizer**  
   Show that when the parser succeeds, the reconstructed components satisfy the lower-bound schema.

Why this is strongest: it separates a mathematically easy semantic theorem from a technically subtle metaprogramming correctness layer. You get publishable structure even if the full extractor is only partial.

### Strategy B: Quoted theorem-instance extraction on named declarations
1. Use `getConstInfo` to inspect theorem declarations by name.
2. Parse their types into the schema.
3. Produce generated definitions `foo_spec : TheorySpec`.
4. Prove generated soundness by reusing the original theorem proof term.

This is more engineering-heavy but highly compelling if it works for the listed bridge theorems. It demonstrates end-to-end automation.

### Strategy C: Reflection theorem over a custom inductive syntax
1. Define a small reflected language for theorem schemas.
2. Reify target theorem statements into that syntax.
3. Prove a correctness theorem from reflected syntax to semantic `TheorySpec`.

This is the cleanest metatheoretically, but likely the longest path. It becomes attractive if direct `Expr` reasoning is too brittle.

**Recommendation:** pursue **Strategy A first**, then extend with the declaration-level automation from **Strategy B**. That gives both a theorem and a usable tool.

---

## How to Build on Existing Catalog Theorems

The listed theorems are not merely examples; they are the validation set for the extractor.

### 1. `depth_lower_bound_from_obstruction`
File: `Bridges/HomologicalDeepLearning.lean`

Use this as a prototype if its type is visibly of the form:
```lean
∀ x, Obstruction x → n ≤ depth x
```
or a variant with parameters. Your extractor should either:
- handle extra parameters by treating them as outer universals before the witness variable, or
- partially apply the theorem to parameters and then extract the final lower-bound schema.

### 2. `purity_lower_bound_from_spectrum`
File: `Bridges/QuantumIdempotent.lean`

This is especially valuable because it has parameters `(k : ℕ) (hk : k > 0)`. This tests whether your extraction handles *parameterized theorem families*. A strong result would be:
```lean
def purity_lower_bound_from_spectrum_spec (k : ℕ) (hk : k > 0) : TheorySpec := ...
```
This demonstrates that extracted semantic objects can depend on theorem parameters.

### 3. `sample_lower_bound_from_shattering`
File: `Bridges/ToposTheoreticML/VCCompactness.lean`

This one is conceptually important: it ties formal learning theory into the extraction framework. If successfully embedded, it shows the system is not tied to one mathematical domain.

### 4. `witness_lower_bound_on_variation`
File: `Bridges/TropicalBarronDuality.lean`

This theorem is likely structurally close to the target schema and should be a strong candidate for immediate extraction.

### 5. `fundamental_cross_domain_bridge`
File: `Bridges/SpectralApplications.lean`

Even if this theorem does not exactly match the schema, test whether your framework can *reject* it gracefully. Negative results matter: a theorem classifier needs both positive and negative examples.

---

## Cross-Domain Connections

This project sits at a remarkable junction:

- **Proof theory:** theorem statements as structured logical objects.
- **Type theory:** dependent signatures encode semantic constraints.
- **Knowledge representation:** extracted `TheorySpec`s are machine-readable mathematical facts.
- **Mathematical AI:** theorem retrieval, theorem clustering, and conjecture transfer.
- **Program synthesis:** proofs become executable semantic artifacts.
- **Category theory / logic:** this resembles a functor from a category of theorem declarations to a category of semantic specifications.
- **NLP / information extraction:** but here the grammar is exact, typed, and verified.
- **Scientific knowledge graphs:** automatic population of bridge graphs from formal corpora.
- **Learning theory:** lower-bound theorems become uniformly queryable objects, enabling meta-analysis of complexity barriers.
- **Physics-inspired mathematics:** “observable” = invariant `inv`, “state predicate” = `Witness`, “conservation law” = lower bound. This is a formal semantics of constraints.

The science-fiction vision is a **Lean-native theorem observatory** in which every proven lower-bound theorem is automatically indexed as a reusable law.

---

## Application Keywords

theorem mining, semantic extraction, reflected syntax, proof metadata, formal knowledge graphs, bridge graph automation, theorem embeddings, dependent type information extraction, certified retrieval, theorem schema recognition, mathematical AI, proof reflection, lower-bound transfer, formal scientific discovery

---

## Deliverables

1. A Lean file defining `TheorySpec` if needed, or adapting to the catalog’s existing notion.
2. A semantic packaging theorem for lower-bound theorems.
3. A partial or total `MetaM` extractor for theorem types of shape `∀ x, P x → n ≤ f x`.
4. A correctness theorem for the extractor on a normalized fragment.
5. At least **two explicit embeddings** of existing catalog theorems into `TheorySpec`.
6. Minimal `sorry`; prioritize proving the semantic theorems completely even if the metaprogramming correctness theorem is partial.

---

## Ambitious Extensions

If the base theorem lands, push immediately toward one of these stronger statements:

### Extension 1: Ordered codomain generalization
Replace `ℕ` with an arbitrary preorder:
```lean
theorem exists_theorySpec_of_ordered_lower_bound_theorem
    (α : Type) (β : Type) [Preorder β]
    (P : α → Prop) (f : α → β) (b : β)
    (h : ∀ x : α, P x → b ≤ f x) :
    ...
```
This would massively widen applicability.

### Extension 2: Conjunctive witness predicates
Handle theorem statements of the form:
```lean
∀ x, P x → Q x → n ≤ f x
```
by extracting `Witness := fun x => P x ∧ Q x`.

### Extension 3: Equality and upper-bound duals
Recognize:
- `f x ≤ n`
- `f x = n`
- `n = f x`

This would create a family of semantic theorem specifications, not just lower bounds.

---

## Tactical Lean Notes

- Work with `Expr.forallE`, `Expr.app`, and the representation of implication as a forall over `Prop`.
- Inequalities will likely appear through `LE.le`.
- You may want helper functions:
  - `stripForalls : Expr → MetaM (Array (Name × Expr) × Expr)`
  - `matchImplication? : Expr → Option (Expr × Expr)`
  - `matchLE? : Expr → Option (Expr × Expr)`
- Keep the extractor partial and explicit. A mathematically honest theorem about a restricted fragment is better than a vague extractor that “usually works.”

---

## Standard of Success

Success is **not** “I wrote a metaprogram that parses some declarations.”
Success is:

- a precise theorem about schema recognition,
- a verified bridge from theorem syntax to semantic specification,
- explicit embeddings of real catalog theorems,
- and a new formal methodology for mining mathematics from mathematics itself.

This is the beginning of a formal theory of **theorem representations**.

---

## Required Final Artifact

You must also produce a structured `FUTURE_DIRECTIONS.md` with **3–5 concrete, breakthrough-level next steps**, such as:

1. generalized extraction for arbitrary preorders and semirings,
2. automatic theorem clustering by extracted invariant structure,
3. conjecture transfer between extracted `TheorySpec`s across domains,
4. a verified theorem search engine keyed by semantic lower-bound patterns,
5. categorical semantics of theorem extraction as a functor from syntax to specifications.

Be concrete. Each next step should be strong enough to seed a full research cycle.

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

Research domain: Bridges
Research mode: prove
