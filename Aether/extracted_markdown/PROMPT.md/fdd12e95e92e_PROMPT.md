## Assignment: Research Package Quality via Certified Mathematical Significance Metrics

Mode: **prove**

Prove new, non-trivial theorems that turn “research significance” from rhetoric into certified mathematics. Build on the catalog theorems, minimize sorry, and force the definitions to be strong enough that they support actual automation in Lean 4.

### Research Direction

The naive ambition — “measure depth, novelty, and impact from proof terms alone” — is philosophically attractive but mathematically too unconstrained to be true in full generality. Your task is to **make it true by choosing the right formal surrogate**: define a significance functional on a lattice of formal knowledge states whose monotonicity and threshold consequences are provable, and whose value is computable from Lean proof-term structure plus a fixed theorem-dependency weight map.

The breakthrough is not a vague metric. It is a **certified semantics of proof significance**: a machine-checkable invariant of formal research objects that (i) respects knowledge growth, (ii) detects structural depth rather than mere theorem count, and (iii) yields automated quality gates with theorems behind them.

This opens a new field: **metamathematical complexity theory for formalized mathematics**. If done correctly, it creates a bridge between theorem proving, lattice-valued semantics, proof complexity, scientometrics, and automated research evaluation.

### Core Formal Vision

Do **not** try to formalize sociological “impact.” Instead formalize a mathematically robust notion:

- a **knowledge state** is a finite set of theorem identifiers or features extracted from proof terms,
- a **significance score** is a weighted, monotone valuation on these finite sets,
- a theorem/proof package is **field-advancing above threshold** if its extracted feature set strictly enlarges the current knowledge state and the valuation crosses a certified cutoff,
- computability comes from recursive feature extraction on proof certificates / dependency DAGs / theorem-use multisets.

This makes the slogan precise: significance is not mystical; it is a **valuation on formal knowledge growth**.

### Precise Theorem Targets

You should introduce concrete definitions and then prove at least the following theorem cluster.

---

## I. Finite-set significance as a monotone valuation

Work with concrete finite knowledge states first; only then abstract to lattices.

Let `α` be a finite type of “atomic certified contributions” (theorem tags, proof motifs, imported bridge lemmas, etc.). Let a weight function `w : α → ℕ`. Define:

- `KnowledgeState α := Finset α`
- `significance (w) (K : Finset α) : ℕ := ∑ a in K, w a`

### Lean 4 target signature
```lean
def KnowledgeState (α : Type*) := Finset α

def significance {α : Type*} [DecidableEq α] (w : α → ℕ) :
    KnowledgeState α → ℕ
  | K => ∑ a in K, w a

theorem significance_monotone_finset
    {α : Type*} [DecidableEq α]
    (w : α → ℕ)
    (hw : Monotone fun n : ℕ => n)
    {K₁ K₂ : KnowledgeState α}
    (h : K₁ ⊆ K₂) :
    significance w K₁ ≤ significance w K₂ := by
  ...
```

You should likely strengthen this to avoid the silly `hw` parameter and instead prove directly under nonnegativity, automatic for `ℕ`-valued weights:

```lean
theorem significance_monotone_finset
    {α : Type*} [DecidableEq α]
    (w : α → ℕ)
    {K₁ K₂ : Finset α}
    (h : K₁ ⊆ K₂) :
    significance w K₁ ≤ significance w K₂ := by
  ...
```

A stronger and more revealing theorem is:

```lean
theorem significance_eq_add_of_disjoint
    {α : Type*} [DecidableEq α]
    (w : α → ℕ)
    {K₁ K₂ : Finset α}
    (hdisj : Disjoint K₁ K₂) :
    significance w (K₁ ∪ K₂) =
      significance w K₁ + significance w K₂ := by
  ...
```

This identifies significance as a **valuation** on the finite distributive lattice of knowledge states.

### Why this matters
Monotonicity alone is cheap. Valuation is the real conceptual upgrade: it means significance behaves like measure, rank, entropy, or dimension on formal knowledge. That is the gateway to a serious theory.

---

## II. Threshold theorems guaranteeing certified advancement

You must define “advances the field” in a way that is mathematically provable. The right move is to define advancement relative to a baseline knowledge state.

Suggested definition:
```lean
def AdvancesField {α : Type*} [DecidableEq α]
    (w : α → ℕ) (τ : ℕ) (K_old K_new : Finset α) : Prop :=
  K_old ⊆ K_new ∧
  significance w K_old < τ ∧
  τ ≤ significance w K_new ∧
  ∃ a ∈ K_new, a ∉ K_old
```

Then prove:

```lean
theorem advances_of_threshold_crossing
    {α : Type*} [DecidableEq α]
    (w : α → ℕ) (τ : ℕ)
    {K_old K_new : Finset α}
    (hsub : K_old ⊆ K_new)
    (hold : significance w K_old < τ)
    (hnew : τ ≤ significance w K_new)
    (hstrict : K_old ≠ K_new) :
    AdvancesField w τ K_old K_new := by
  ...
```

Even better, prove a lower-bound theorem exhibiting **minimum certified novelty**:

```lean
theorem threshold_crossing_yields_new_weight
    {α : Type*} [DecidableEq α]
    (w : α → ℕ) (τ : ℕ)
    {K_old K_new : Finset α}
    (hsub : K_old ⊆ K_new)
    (hold : significance w K_old < τ)
    (hnew : τ ≤ significance w K_new) :
    ∃ a ∈ K_new, a ∉ K_old := by
  ...
```

This theorem is subtle: it says threshold crossing is impossible without genuinely new certified content. That is the formal core of an automated quality gate.

### Breakthrough significance
This gives the first machine-checkable theorem of the form:

> “A package that crosses a certified significance threshold cannot be merely a repackaging of existing formal knowledge.”

That is a real metamathematical statement, not an opinion.

---

## III. Computability from proof-term structure alone

Here you must be careful and formalize a surrogate that Lean can actually compute.

Do **not** attempt to introspect arbitrary kernel proof terms directly unless there is already infrastructure. Instead define a datatype of **abstract proof skeletons** or **certified dependency trees** and prove significance computability there. Then explain in comments that Lean theorem elaboration can export such skeletons.

Suggested inductive type:
```lean
inductive ProofShape (α : Type*)
  | ax    : α → ProofShape α
  | app   : ProofShape α → ProofShape α → ProofShape α
  | lam   : ProofShape α → ProofShape α
  | pair  : ProofShape α → ProofShape α → ProofShape α
deriving DecidableEq, Repr
```

Define extracted feature set:
```lean
def ProofShape.features {α : Type*} [DecidableEq α] : ProofShape α → Finset α
  | .ax a      => {a}
  | .app p q   => p.features ∪ q.features
  | .lam p     => p.features
  | .pair p q  => p.features ∪ q.features
```

Define significance from proof shape:
```lean
def significanceFromProofShape {α : Type*} [DecidableEq α]
    (w : α → ℕ) (p : ProofShape α) : ℕ :=
  significance w p.features
```

Then prove computability and monotonicity under embedding/subproof relations:
```lean
def ProofShape.size {α : Type*} : ProofShape α → ℕ
  | .ax _      => 1
  | .app p q   => p.size + q.size + 1
  | .lam p     => p.size + 1
  | .pair p q  => p.size + q.size + 1

theorem significanceFromProofShape_computable
    {α : Type*} [DecidableEq α]
    (w : α → ℕ) :
    ∃ f : ProofShape α → ℕ, f = significanceFromProofShape w := by
  ...
```

More meaningfully:
```lean
theorem significanceFromProofShape_le_weighted_size
    {α : Type*} [DecidableEq α]
    (w : α → ℕ)
    (hw : ∀ a, w a ≤ C)
    (p : ProofShape α) :
    significanceFromProofShape w p ≤ C * p.size := by
  ...
```

and

```lean
theorem significanceFromProofShape_monotone_under_feature_inclusion
    {α : Type*} [DecidableEq α]
    (w : α → ℕ)
    {p q : ProofShape α}
    (h : p.features ⊆ q.features) :
    significanceFromProofShape w p ≤ significanceFromProofShape w q := by
  ...
```

This directly builds on the catalog theorem `significance_from_proofs_monotone`.

### Why this is the right formalization
The statement “computed from proof term structure alone” becomes true in a certified sense: significance depends only on recursively extracted structural features. This is formalizable now, extensible later to actual Lean expressions.

---

## IV. Lift from finite sets to an order-theoretic lattice theorem

Once the finite-set version is established, package it as a lattice theorem. Use `Finset α` ordered by inclusion, or `Set α` if you want a complete lattice and can manage finitary support through finite weighted support.

A good theorem target is:

```lean
theorem significance_monotone_lattice
    {α : Type*} [DecidableEq α]
    (w : α → ℕ) :
    Monotone (significance w) := by
  ...
```

where monotonicity is with respect to `≤` on `Finset α`.

If you can push farther, prove a modularity/submodularity statement:
```lean
theorem significance_union_inter
    {α : Type*} [DecidableEq α]
    (w : α → ℕ)
    (K₁ K₂ : Finset α) :
    significance w (K₁ ∪ K₂) + significance w (K₁ ∩ K₂) =
      significance w K₁ + significance w K₂ := by
  ...
```

This is mathematically far stronger than monotonicity. It says significance is a **modular rank-like functional**. That places the theory in the orbit of matroid rank, information measures, and valuation theory.

### Revolutionary significance
If you prove this theorem, you are no longer proposing a metric. You are uncovering a **formal geometry of research progress**.

---

## How to Build on the Existing Verified Theorems

1. `significance_from_proofs_monotone`
   - Use this as your immediate bridge theorem: your new `ProofShape.features`-based significance should be shown to instantiate or refine the monotonicity pattern already verified in `MachineLearning/SignificanceTheory/Core.lean`.
   - If its statement is abstract, specialize it to your concrete `ProofShape` feature-extraction map.

2. `proof_class_monotone`
   - This suggests an existing monotonicity theorem indexed by proof complexity/class.
   - Use it to relate coarse proof classes (`k₁ ≤ k₂`) to your finer weighted significance valuation. A powerful target is to prove that your metric refines proof-class monotonicity:
   ```lean
   theorem proof_class_monotone_refined_by_significance ...
   ```

3. `and_bool_monotone`
   - This may seem elementary, but it can serve as the atomic monotone-combinator lemma if you encode quality gates as Boolean predicates on threshold conditions.
   - Example: define a Boolean gate requiring both novelty and threshold crossing, then prove monotonicity of the gate under knowledge growth.

4. `tropChar_class_function`
   - Use this as a cross-domain witness theorem: assign elevated weights to bridge theorems connecting distant fields (e.g. tropical representation theory to proof semantics).
   - This lets you formalize a “cross-domain novelty premium” without handwaving: significance is larger when the proof imports atoms from multiple weighted domains.

5. `key_dimension_lower_bound_from_height`
   - This theorem suggests a lower-bound mechanism: structural height implies nontrivial dimension.
   - Analogously, prove lower bounds showing proof-structure height or feature diversity forces minimum significance:
   ```lean
   theorem significance_lower_bound_from_feature_height ...
   ```

This would be especially compelling: significance is not only monotone, it is **forced upward by structural depth**.

---

## Suggested Definitions That Are Actually Strong

A weak metric counts theorem uses. A strong metric detects cross-domain synthesis.

Consider enriching weights to decompose into:
- `depthWeight : α → ℕ`
- `noveltyWeight : α → ℕ`
- `bridgeWeight : α → ℕ`

and define:
```lean
def significanceTriple {α : Type*} [DecidableEq α]
    (d n b : α → ℕ) (K : Finset α) : ℕ :=
  significance d K + significance n K + significance b K
```

Then prove monotonicity componentwise and jointly.

A major theorem target:
```lean
theorem significanceTriple_monotone
    {α : Type*} [DecidableEq α]
    (d n b : α → ℕ) :
    Monotone (significanceTriple d n b) := by
  ...
```

Then define a “master-class contribution” threshold:
```lean
def MasterClass {α : Type*} [DecidableEq α]
    (d n b : α → ℕ) (τ : ℕ) (K : Finset α) : Prop :=
  τ ≤ significanceTriple d n b K
```

and prove closure/monotonicity:
```lean
theorem masterClass_upward_closed
    {α : Type*} [DecidableEq α]
    (d n b : α → ℕ) (τ : ℕ) :
    Set.MapsTo ?f ?A ?B := ...
```
or simply:
```lean
theorem masterClass_monotone
    {α : Type*} [DecidableEq α]
    (d n b : α → ℕ) (τ : ℕ)
    {K₁ K₂ : Finset α}
    (h : K₁ ⊆ K₂)
    (hk : MasterClass d n b τ K₁) :
    MasterClass d n b τ K₂ := by
  ...
```

---

## Proof Strategy Architecture

### Strategy A: Finset valuation route — most promising
1. Define significance on `Finset α` by weighted sum.
2. Prove monotonicity via `Finset.sum_le_sum_of_subset` or by decomposing `K₂ = K₁ ∪ (K₂ \ K₁)`.
3. Prove threshold-crossing theorems using contradiction: if no new atom exists, then `K_old = K_new`, hence significance equal, contradicting threshold crossing.

**Why most promising:** this path is fully constructive, uses standard Mathlib combinatorics, and will produce strong theorems with minimal infrastructure.

### Strategy B: Lattice-theoretic abstraction route
1. Package `Finset α` as a distributive lattice under inclusion.
2. Show significance is a valuation and therefore monotone.
3. Deduce threshold properties from strict order growth and valuation positivity.

**Why powerful:** this yields cleaner theorems and a reusable abstract framework, but may require more order-theory setup than Strategy A.

### Strategy C: Structural proof-shape recursion route
1. Define `ProofShape` and recursive feature extraction.
2. Prove feature extraction is computable by definition and significance is computable as a recursive fold.
3. Connect recursive structure to significance bounds and monotonicity under feature inclusion.

**Why transformative:** this is the route that makes the “proof-term-only quality gate” slogan mathematically legitimate. It is slightly more engineering-heavy but philosophically central.

Recommended execution order: **A → C → B**. First secure the valuation theorems, then the computability story, then the lattice packaging.

---

## Cross-Domain Connections You Should Explicitly Exploit

1. **Proof complexity / circuit complexity**
   - Your `ProofShape.size` and feature-extraction map mirror circuit size and support.
   - Significance lower bounds from proof height are analogous to complexity lower bounds.

2. **Information theory**
   - The modularity theorem
     \[
     s(K₁ ∪ K₂) + s(K₁ ∩ K₂) = s(K₁) + s(K₂)
     \]
     makes significance look like a finitely additive information functional.
   - This invites future work on formal mutual information between theorem families.

3. **Matroid/rank theory**
   - A monotone modular valuation is rank-like.
   - This suggests formalizing “independent contributions” and “redundant repackaging” as closure/dependence phenomena.

4. **Scientometrics without sociology**
   - Your theory replaces citation-count mythology with theorem-dependency geometry.
   - The significance of a result is certified by structural contribution, not external popularity.

5. **Tropical / idempotent mathematics**
   - Since the catalog contains tropical and idempotent bridge theorems, consider max-plus or min-plus variants of significance aggregation.
   - A tropical significance semiring could model “best breakthrough dimension dominates” rather than additive accumulation.

6. **Cryptographic invariant theory**
   - The theorem `key_dimension_lower_bound_from_height` hints that structural height forces latent complexity.
   - Transfer that pattern: proof height / domain diversity / dependency diameter imply significance lower bounds.

---

## Concrete Ambitious Theorem Package

A compelling file should contain something like the following targets.

```lean
def KnowledgeState (α : Type*) := Finset α

def significance {α : Type*} [DecidableEq α] (w : α → ℕ) (K : KnowledgeState α) : ℕ :=
  ∑ a in K, w a

theorem significance_monotone_finset
    {α : Type*} [DecidableEq α]
    (w : α → ℕ) :
    Monotone (significance w) := by
  ...

theorem significance_union_inter
    {α : Type*} [DecidableEq α]
    (w : α → ℕ) (K₁ K₂ : Finset α) :
    significance w (K₁ ∪ K₂) + significance w (K₁ ∩ K₂) =
      significance w K₁ + significance w K₂ := by
  ...

def AdvancesField {α : Type*} [DecidableEq α]
    (w : α → ℕ) (τ : ℕ) (K_old K_new : Finset α) : Prop :=
  K_old ⊆ K_new ∧ significance w K_old < τ ∧ τ ≤ significance w K_new ∧
  ∃ a ∈ K_new, a ∉ K_old

theorem advances_of_threshold_crossing
    {α : Type*} [DecidableEq α]
    (w : α → ℕ) (τ : ℕ)
    {K_old K_new : Finset α}
    (hsub : K_old ⊆ K_new)
    (hold : significance w K_old < τ)
    (hnew : τ ≤ significance w K_new) :
    K_old ≠ K_new → AdvancesField w τ K_old K_new := by
  ...

inductive ProofShape (α : Type*)
  | ax   : α → ProofShape α
  | app  : ProofShape α → ProofShape α → ProofShape α
  | lam  : ProofShape α → ProofShape α
  | pair : ProofShape α → ProofShape α → ProofShape α
deriving DecidableEq, Repr

def ProofShape.features {α : Type*} [DecidableEq α] : ProofShape α → Finset α
  | .ax a      => {a}
  | .app p q   => p.features ∪ q.features
  | .lam p     => p.features
  | .pair p q  => p.features ∪ q.features

def significanceFromProofShape {α : Type*} [DecidableEq α]
    (w : α → ℕ) (p : ProofShape α) : ℕ :=
  significance w p.features

theorem significanceFromProofShape_monotone_under_feature_inclusion
    {α : Type*} [DecidableEq α]
    (w : α → ℕ)
    {p q : ProofShape α}
    (h : p.features ⊆ q.features) :
    significanceFromProofShape w p ≤ significanceFromProofShape w q := by
  ...
```

If time permits, add:
```lean
def domainCoverage {α β : Type*} [DecidableEq β] (tag : α → β) (K : Finset α) : Finset β :=
  (K.image tag)

theorem significance_lower_bound_from_domain_coverage
    {α β : Type*} [DecidableEq α] [DecidableEq β]
    (w : α → ℕ) (tag : α → β)
    (hpos : ∀ a, 1 ≤ w a)
    (K : Finset α) :
    (domainCoverage tag K).card ≤ significance w K := by
  ...
```

This theorem would certify that broad cross-domain reach forces nontrivial significance.

---

## What Would Count as a Genuine Breakthrough Here

A result is genuinely new if you prove one of these stronger statements:

- **Modularity/submodularity** of significance on knowledge lattices.
- **Lower bounds from structural depth**: proof height, dependency diameter, or domain coverage imply significance.
- **Threshold crossing implies novelty** in a theorem, not by definition.
- **Computability from proof skeleton alone** with explicit recursive extraction.
- **Cross-domain bonus formalization**: significance provably increases with certified domain diversity.

Any one of these, formalized cleanly in Lean, would establish a serious new direction.

---

## Guardrails

- Do not claim a universal theorem that any significance threshold “guarantees advance of the field” unless “advance” is formally defined as certified novelty plus threshold crossing relative to a baseline.
- Avoid sociological language unless translated into exact predicates.
- Use concrete types: `Finset`, `ℕ`, finite tags, recursive proof-shape trees.
- Minimize abstraction debt; get real theorems proved.

---

## Deliverables

1. A Lean file formalizing the significance framework and proving the theorem cluster above.
2. Clear comments indicating where the catalog theorems are used or refined.
3. At least one theorem that is stronger than plain monotonicity.
4. A structured `FUTURE_DIRECTIONS.md` with **3–5 concrete breakthrough next steps**, such as:
   - formal mutual information between theorem families,
   - matroidal independence of research contributions,
   - tropical/max-plus significance semantics,
   - dependency-graph spectral significance,
   - extraction from actual Lean `Expr` proof terms.

## Application Keywords

formal metamathematics, proof complexity, lattice valuation, theorem-proving semantics, automated quality gates, certified novelty, dependency graphs, proof-term analysis, scientometrics, matroid rank, information theory, tropical semantics, knowledge lattices, structural proof metrics, Lean 4 automation

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

Research domain: Speculative
Research mode: prove
