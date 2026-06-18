Soli Deo Gloria

## Assignment: Direction 1: Intrinsically Typed Higher-Order Rewriting with βη-Completion

**Mode:** prove

Build a genuinely new formal bridge between higher-order rewriting, typed abstract syntax, and extensional normalization theory. The target is not merely to port untyped lemmas into an indexed setting, but to show that **βη-stable higher-order equational generation is intrinsic, substitutional, and quotient-compatible** for simply typed syntax. This would open a path toward certified completion procedures for extensional functional programs, typed proof assistants, and normalization-by-evaluation pipelines.

You must prove new, non-trivial theorems, build explicitly on catalog theorems, and minimize sorry.

## Why this is a breakthrough

The catalog already contains higher-order completion technology in the untyped or less intrinsically structured setting. What is missing is the decisive extensional step: a theory of **intrinsically typed higher-order rewriting modulo βη** where all terms are well-scoped and well-typed by construction, substitution is structurally functorial, and generated equations descend to βη-quotients without any ad hoc side conditions. This is the point where rewriting ceases to be merely syntactic bookkeeping and becomes a mathematically robust semantics for extensional computation.

If you establish this cleanly, you open at least four fronts at once:

1. **Higher-order completion modulo extensionality:** completion procedures can reason about functions up to η, not only β.
2. **Semantics of typed rewriting:** βη-quotients become legitimate ambient spaces for equational generation.
3. **Programming language metatheory:** extensional optimization passes can be justified as rewrite systems modulo βη.
4. **Categorical syntax and semantics:** the intrinsic syntax should align with Fiore–Plotkin–Turi style substitutional structure and with cartesian closed semantics.

This is not an incremental variant of `subst_comp`; it is the typed, extensional closure theorem that the untyped theory has been pointing toward.

---

## Core theorem package to formalize

You should introduce an intrinsically typed syntax of simply typed λ-terms using de Bruijn indices.

### Suggested type universe
Use a simple base/function type grammar, for example:
```lean
inductive Ty where
  | base : Nat → Ty
  | arr  : Ty → Ty → Ty
deriving DecidableEq
```

Use contexts as lists/vectors of types, and terms indexed by context and type:
```lean
def Ctx := List Ty

inductive Tm : Ctx → Ty → Type where
  | var : Var Γ A → Tm Γ A
  | app : Tm Γ (Ty.arr A B) → Tm Γ A → Tm Γ B
  | lam : Tm (A :: Γ) B → Tm Γ (Ty.arr A B)
```
You may choose your own `Var` representation, but it must be intrinsic.

Define:
- renaming
- substitution
- lifting/weakening of substitutions
- one-step β-reduction
- one-step η-contraction or η-expansion, with the usual side condition encoded intrinsically
- reflexive-transitive/symmetric-transitive closures as needed
- higher-order equation generation `HOEqGen` in the typed setting
- a new concept not already in the catalog, e.g. **βη-stable typed rewrite theory** or **extensional closure system**

A good candidate for a novel structure is:

```lean
structure BetaEtaStableTheory where
  Rule      : ∀ {Γ A}, Tm Γ A → Tm Γ A → Prop
  subst_closed :
    ∀ {Γ Δ A} {t u : Tm Γ A}, Rule t u →
      ∀ (σ : Sub Γ Δ), HOEqGen Rule (subst σ t) (subst σ u)
  beta_included :
    ∀ {Γ A} {t u : Tm Γ A}, BetaStep t u → Rule t u
  eta_included  :
    ∀ {Γ A} {t u : Tm Γ A}, EtaStep t u → Rule t u
```

This is mathematically meaningful: it packages exactly the closure needed for quotient descent.

---

## Precise theorem statements

You must prove at least 3 substantial theorems. The following package is the minimum target.

### Theorem 1: typed substitution composition
This is the foundational intrinsic analogue of the catalog’s `subst_comp`.

**Mathematical statement.**  
For all contexts `Γ Δ Ξ`, all types `A`, all terms `t : Tm Γ A`, all substitutions `σ : Sub Γ Δ` and `τ : Sub Δ Ξ`,
\[
\operatorname{subst}\,\tau(\operatorname{subst}\,\sigma\,t)
=
\operatorname{subst}\,(\tau \circ \sigma)\,t.
\]

**Lean 4 type signature (suggested):**
```lean
theorem subst_comp
  {Γ Δ Ξ : Ctx} {A : Ty}
  (t : Tm Γ A) (σ : Sub Γ Δ) (τ : Sub Δ Ξ) :
  subst τ (subst σ t) = subst (compSub τ σ) t
```

This theorem must be proved structurally, not by simplification alone. The `lam` case should require a genuine interaction between lifted substitutions and induction hypotheses.

---

### Theorem 2: η-step is stable under substitution
This is the first truly new extensional lemma. It is the hinge on which βη-closure turns.

**Mathematical statement.**  
If `t →η u`, then for every substitution `σ`, one has `subst σ t →η* subst σ u` (or directly `→η`, depending on your exact η-step definition).

A canonical η-contraction is:
\[
\lambda x.\, f\,x \to_\eta f
\]
when `x` is not free in `f`. Intrinsically, this should be represented by a term of the form
\[
\lambda(\operatorname{app}(\operatorname{rename}\,\mathsf{succ}\,f,\operatorname{var}\,0))
\to_\eta f.
\]

**Lean 4 type signature (suggested):**
```lean
theorem eta_closed_under_subst
  {Γ Δ : Ctx} {A B : Ty}
  {f : Tm Γ (Ty.arr A B)} {σ : Sub Γ Δ} :
  EtaStep (Tm.lam (Tm.app (rename wk f) (Tm.var vz))) f →
  HOEqGen EtaStep
    (subst σ (Tm.lam (Tm.app (rename wk f) (Tm.var vz))))
    (subst σ f)
```
or, if you define η as a primitive schema:
```lean
theorem eta_closed_under_subst
  {Γ Δ : Ctx} {A : Ty}
  {t u : Tm Γ A} (h : EtaStep t u) (σ : Sub Γ Δ) :
  HOReflTransGen EtaStep (subst σ t) (subst σ u)
```

This theorem is not a routine clone of the β-case; the point is to formalize exactly how lifted substitutions commute with the η-shape.

---

### Theorem 3: higher-order equational generation is βη-congruence stable
This is the flagship result.

**Mathematical statement.**  
Let `E` be a typed rewrite theory containing β- and η-rules and closed under substitution. If `HOEqGen E t u`, `t ≈βη t'`, and `u ≈βη u'`, then `HOEqGen E t' u'`.

Equivalently: the generated equational theory descends to βη-equivalence classes.

**Lean 4 type signature (suggested):**
```lean
theorem hoEqGen_respects_betaEta
  {Γ : Ctx} {A : Ty}
  (E : ∀ {Γ A}, Tm Γ A → Tm Γ A → Prop)
  (hsub :
    ∀ {Γ Δ A} {t u : Tm Γ A},
      E t u → ∀ σ : Sub Γ Δ, HOEqGen E (subst σ t) (subst σ u))
  (hβ :
    ∀ {Γ A} {t u : Tm Γ A}, BetaStep t u → E t u)
  (hη :
    ∀ {Γ A} {t u : Tm Γ A}, EtaStep t u → E t u)
  {t t' u u' : Tm Γ A} :
  HOEqGen E t u →
  BetaEtaEq t t' →
  BetaEtaEq u u' →
  HOEqGen E t' u'
```

A stronger quotient statement is even better:

```lean
theorem hoEqGen_descends_to_betaEta_quotient
  (E : ...)
  (hstable : BetaEtaStableTheory ...)
  :
  ∃ Rq : BetaEtaQuot Γ A → BetaEtaQuot Γ A → Prop,
    ∀ t u, Rq ⟦t⟧ ⟦u⟧ ↔ HOEqGen E t u
```

If you can make this precise, it would be a major conceptual leap.

---

### Theorem 4: normalization commutes with rewriting for orthogonal βη-stable systems
This is more ambitious, but if you can reach it, it is field-opening.

**Mathematical statement.**  
For orthogonal typed rule sets `E`, βη-normalization is compatible with `HOEqGen E`: rewriting before normalization and normalization before rewriting produce βη-equivalent outputs.

**Lean 4 type signature (schematic):**
```lean
theorem normalize_commutes_with_rewriting
  (E : ...)
  (horth : Orthogonal E)
  (hstable : BetaEtaStableTheory E)
  {Γ : Ctx} {A : Ty} {t u : Tm Γ A} :
  HOEqGen E t u →
  BetaEtaEq (normalize t) (normalize u)
```

If full normalization is too large for one cycle, prove a local diamond / postponement / commutation theorem instead.

---

## Required proof strategy architecture

You must not rely on trivial automation. Use induction, `rcases`, `by_contra`, nontrivial `calc`, and careful transport across typed indices.

### Strategy A: Autosubst-style intrinsic algebra of renaming/substitution
This is the most promising route.

1. **Define renamings and substitutions as typed environment morphisms.**  
   Make `Ren Γ Δ := ∀ {A}, Var Γ A → Var Δ A` and `Sub Γ Δ := ∀ {A}, Var Γ A → Tm Δ A`.
2. **Prove the renaming/substitution interaction lemmas first.**  
   You will need `rename_comp`, `lift_rename`, `lift_subst`, `rename_subst`, `subst_rename`, and especially the lifted composition lemma analogous to `liftSubst_compSubst`.
3. **Derive β- and η-substitution closure from the infrastructure.**  
   The η case should reduce to a carefully formulated lifted-substitution identity inside the `lam/app/var` pattern.
4. **Lift closure from one-step rules to generated equations.**  
   Use induction on the derivation of `HOEqGen`.

Why this is most promising: it aligns directly with the catalog’s `HigherOrderCompletion.lean`, but the intrinsic typing will force coherence conditions that make the extensional theorem stronger and cleaner.

---

### Strategy B: Categorical substitution as a presheaf/CwF argument
This is more conceptual and could yield cleaner quotient descent.

1. Model `Tm` as a presheaf over contexts or as syntax in a category with families.
2. Interpret renaming and substitution as functorial action and Kleisli extension.
3. Express β and η as equations stable under reindexing/substitution.
4. Deduce quotient descent by universal properties of the βη-congruence.

Why this is powerful: if successful, it gives not just proofs but a structural explanation of why βη-stability is inevitable. It also creates a direct bridge to Fiore–Plotkin–Turi style abstract syntax and categorical semantics of binding.

Risk: formal overhead may be high in Lean unless carefully scoped.

---

### Strategy C: Parallel βη reduction / residual theory
Use this if you aim for the normalization-commutation theorem.

1. Define a parallel βη relation on intrinsically typed terms.
2. Prove substitution stability and a key diamond or strip lemma.
3. Show generated rewriting commutes with parallel βη under orthogonality assumptions.
4. Conclude quotient compatibility or normalization commutation.

Why this matters: this route scales toward confluence and completion modulo βη. It is the correct path if your ambition is algorithmic completion, not only closure lemmas.

---

## Explicit catalog building blocks

You must explicitly build on and cite the following catalog artifacts in your code comments and research paper:

- `Pythagorean/HigherOrderCompletion.lean`  
  Use its untyped or less-indexed lemmas as prototypes:
  - `subst_comp`
  - `beta_closed_under_subst`
  - `liftSubst_compSubst`

- `Pythagorean/ConcreteTermAlgebra.lean`  
  Use `FOTerm.subst_comp` as the first-order prototype and explain how intrinsic typing changes the proof obligations.

The point is not to reprove the same theorem in a prettier syntax. The point is to **identify exactly which arguments survive intrinsic typing unchanged, which become stronger, and which require genuinely new extensional lemmas**.

---

## Cross-domain connections you must include

At least one theorem and the surrounding discussion must connect this development to another mathematical domain.

### Bridge 1: Category theory / semantics of binding
Show that typed substitutions form a category-like structure and terms form a presheaf/CwF-style object. Even a theorem as simple as associativity of substitution composition, interpreted categorically, is valuable if stated explicitly as a semantics theorem.

Possible theorem:
```lean
theorem typed_substitution_category_law
  {Γ Δ Ξ Ω : Ctx} (σ : Sub Γ Δ) (τ : Sub Δ Ξ) (υ : Sub Ξ Ω) :
  compSub υ (compSub τ σ) = compSub (compSub υ τ) σ
```
This should not be left as extensional triviality; prove it in a way that supports the semantics discussion.

### Bridge 2: Programming languages / compiler correctness
State and, if possible, prove a theorem saying that βη-normal forms are invariant under extensional rewrites generated by an orthogonal theory. This directly connects to verified optimization of higher-order functional programs.

### Bridge 3: Logic / proof theory
Explain that βη-equivalence is definitional equality for simply typed proofs, so your quotient-descent theorem says rewrite-generated equalities are stable under proof normalization. This is a bridge to normalization and proof identity.

---

## Conjecture with testable prediction

You must state at least one falsifiable conjecture and provide a computational test in `demo.py` that could disprove it.

### Conjecture: orthogonal βη-stable systems are normalization-compatible
For every finite orthogonal typed rule set `E` on simply typed λ-terms of order ≤ 2 and every closed term `t` of size ≤ 12, the βη-normal form of `t` is βη-equivalent to the βη-normal form of any `u` such that `HOEqGen E t u`.

This is falsifiable: enumerate small well-typed closed terms and small orthogonal rule sets, search for a counterexample.

A sharper version:
> For orthogonal βη-stable `E`, if `t` and `u` are related by one `E`-rewrite, then `normalize t` and `normalize u` are α-equivalent.

If false, your search should find a witness. If true in all tested cases, it strongly motivates the next theorem cycle.

---

## Implementation targets

You must produce all of the following:

1. **Lean file(s)** formalizing the intrinsic syntax and proving at least 3 nontrivial theorems with deep proof steps.
2. **A verified algorithm or computational method**, not just theorem statements.  
   Examples:
   - βη-normalizer for intrinsically typed terms
   - orthogonality checker for finite typed rule sets
   - decision procedure for one-step η-redex detection
3. **`demo.py`** demonstrating:
   - generation of small typed terms
   - βη-normalization
   - sample rewrite closure checks
   - the conjecture test up to size 12
4. **`RESEARCH_PAPER.md`** as a standalone scientific paper:
   - define the syntax and problem from scratch
   - explain why βη-stable rewriting matters
   - state the main theorems and proof ideas
   - discuss applications and limitations
   - identify what comes next
5. **`ARTICLE.md`** in Scientific American style:
   - explain the discovery accessibly
   - emphasize extensional computation, typed syntax, and why functions should be identified when they act the same
   - taboo: do **not** focus on formal verification machinery
6. **`FUTURE_DIRECTIONS.md`** with 3–5 original directions.  
   Each direction must include the exact sentences:
   - “The key insight is ...”
   - “Why now? ...”
   At least one direction must bridge to a different domain.

---

## Suggested theorem list beyond the minimum

These are strong candidates if the core package is completed:

```lean
theorem rename_subst
  {Γ Δ Ξ : Ctx} {A : Ty}
  (t : Tm Γ A) (ρ : Ren Γ Δ) (σ : Sub Δ Ξ) :
  subst σ (rename ρ t) = subst (fun v => σ (ρ v)) t
```

```lean
theorem subst_rename
  {Γ Δ Ξ : Ctx} {A : Ty}
  (t : Tm Γ A) (σ : Sub Γ Δ) (ρ : Ren Δ Ξ) :
  rename ρ (subst σ t) = subst (fun v => rename ρ (σ v)) t
```

```lean
theorem betaEtaEq_congr_app
  {Γ : Ctx} {A B : Ty}
  {f f' : Tm Γ (Ty.arr A B)} {t t' : Tm Γ A} :
  BetaEtaEq f f' → BetaEtaEq t t' →
  BetaEtaEq (Tm.app f t) (Tm.app f' t')
```

```lean
theorem betaEtaEq_congr_lam
  {Γ : Ctx} {A B : Ty}
  {t u : Tm (A :: Γ) B} :
  BetaEtaEq t u → BetaEtaEq (Tm.lam t) (Tm.lam u)
```

```lean
theorem hoRewrites_closed_under_subst_typed
  {Γ Δ : Ctx} {A : Ty}
  {t u : Tm Γ A} (h : HOEqGen E t u) (σ : Sub Γ Δ) :
  HOEqGen E (subst σ t) (subst σ u)
```

```lean
theorem betaEtaEq_is_equivalence
  {Γ : Ctx} {A : Ty} :
  Equivalence (@BetaEtaEq Γ A)
```

```lean
theorem quotient_soundness
  {Γ : Ctx} {A : Ty} {t u : Tm Γ A} :
  HOEqGen E t u → Quot.sound (show BetaEtaEq t u from ...)
```

---

## Mathematical insight to emphasize in the paper

The deep point is this:

- **β-stability** says rewriting respects computation.
- **η-stability** says rewriting respects extensionality.
- **Intrinsic typing** says these properties are not accidental side conditions but structural facts of the syntax.
- Therefore, **higher-order rewriting modulo βη becomes a semantics-level object**, not merely a syntactic relation.

This is the conceptual leap. In extensional settings, functions are determined by their action. A rewrite theory that fails to descend to βη-classes is semantically brittle. Your goal is to remove that brittleness.

---

## Application keywords

Use these explicitly in the paper, article, comments, and demo:

- higher-order rewriting
- simply typed λ-calculus
- βη-equivalence
- intrinsic typing
- de Bruijn indices
- substitution calculus
- extensional equality
- orthogonality
- normalization
- completion procedures
- categorical semantics
- cartesian closed categories
- compiler correctness
- proof normalization
- rewriting modulo
- abstract syntax with binding

---

## Nontriviality requirements

These are mandatory.

1. Do **not** choose statements whose proof is essentially `rfl`, `decide`, or brute-force enumeration.
2. At least 3 theorems must require substantial proof structure, ideally:
   - induction on terms or derivations
   - `rcases` on typed constructors
   - multi-step `calc`
   - contradiction arguments for impossible typed variable cases
3. At least one proof must visibly depend on the interaction between `lam` and lifted substitution.
4. At least one theorem must be a genuine cross-domain theorem, not merely a remark.

---

## Final call

Do not treat this as a syntax engineering exercise. Treat it as the first rigorous step toward a theory of **extensional higher-order completion on intrinsically typed syntax**. The right result here would not just clean up an implementation detail; it would clarify what a higher-order rewrite system is supposed to mean when functions are identified by behavior rather than presentation.

Produce a Lean development that makes that statement mathematically unavoidable.

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
- **Visualization scripts** — Produce up to 3 self-contained Python scripts
  that visually illustrate the core mathematical concepts discovered. Use
  matplotlib for static plots (heatmaps, curves, surfaces) or plotly for
  interactive charts. Available libraries: numpy, matplotlib, plotly.
  If using matplotlib, the script must call plt.savefig() — the system
  captures the output as a PNG. If using plotly, assign the figure to a
  variable named `fig` — the system captures fig.to_html(). Each script
  must include a comment header explaining what it visualizes and why.
  **CRITICAL: Each visualization script MUST be a single, fully self-contained
  file. Do NOT import from any local modules (algorithms.py, demo.py, etc.).
  Instead, inline all needed functions and classes directly in the script.
  The browser runtime (Pyodide) has no access to local .py files.**
- **Interactive HTML demos** — Produce up to 3 self-contained HTML snippets
  (with inline CSS/JS, no external dependencies) that demonstrate the
  mathematical concepts interactively — sliders, animations, dynamic SVG,
  or canvas drawing. Each demo must be a complete <div> fragment that
  works when inserted into a page. No <html>, <head>, or <body> tags —
  just the content div with its inline styles and scripts.

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
    "visualizations": [ { "name": "...", "code": "# Must be 100% self-contained. Do not import local files. Inline all needed functions directly.", "description": "What this visualizes" } ],
    "interactive_demos": [ { "name": "...", "html": "<div>...</div>", "description": "What this demonstrates" } ],
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

Research domain: Pythagorean
Research mode: prove
