## Assignment: 3. Build a Reflection Tactic Using `normalize_ca`

**Mode:** `prove`

Build not merely a convenience tactic, but a **certified decision procedure for the additive-commutative fragment of tropical algebra**. The right target is not “some automation for `min` and `+`,” but a Lean-native analogue of `ring`: a tactic that transforms tropical identity proving from ad hoc rewriting into **reflection-backed computation with a theorem-level correctness guarantee**.

This is the seed of a new automation layer for tropical mathematics in Lean.

---

## Vision

The completeness statement

- `ACEquiv e₁ e₂ → normalize_ca e₁ = normalize_ca e₂`

should be upgraded into a **reflection theorem** saying that if two concrete tropical expressions reify to the same canonical form, then their semantic interpretations are equal. Once this is done, a tactic can solve a substantial class of goals of the form

- `⊢ t₁ = t₂`
- where `t₁, t₂` are built from variables, constants, tropical addition `min`, and tropical multiplication `+`

by:
1. reifying both sides,
2. normalizing,
3. checking syntactic equality,
4. discharging the original goal by a certified soundness theorem.

This is mathematically modest in statement but strategically explosive: it creates the first **proof-producing tropical normalization engine**, and opens the road to automation for tropical semiring algebra, tropical convexity certificates, and eventually tropical Gröbner-style computation.

---

## Precise theorem targets

You should aim to formalize a theorem package around reflection, not just an interactive tactic script.

### 1. Semantic soundness of canonical normalization

Define or identify:
- a syntax type `TropExpr`,
- an evaluator `eval : TropExpr → (Var → ℝ) → ℝ` or similar,
- a canonicalizer `normalize_ca : TropExpr → TropExpr`,
- an equivalence relation `ACEquiv : TropExpr → TropExpr → Prop`.

Then prove the core theorem:

```lean
theorem normalize_ca_sound
    (e : TropExpr) (σ : Var → ℝ) :
    eval (normalize_ca e) σ = eval e σ
```

If the current library already proves soundness indirectly through `ACEquiv`, then package it in this direct semantic form.

### 2. Reflection theorem for equality of tropical expressions

The main theorem should be:

```lean
theorem tropical_reflection_complete
    (e₁ e₂ : TropExpr) :
    normalize_ca e₁ = normalize_ca e₂ →
    ∀ σ : Var → ℝ, eval e₁ σ = eval e₂ σ
```

A stronger and more useful extensional version is preferable:

```lean
theorem tropical_reflection_iff
    (e₁ e₂ : TropExpr) :
    (normalize_ca e₁ = normalize_ca e₂) ↔
    (∀ σ : Var → ℝ, eval e₁ σ = eval e₂ σ)
```

If the reverse implication is too ambitious because `normalize_ca` is complete only for `ACEquiv` and not all semantic equality, then prove the strongest valid variant:

```lean
theorem tropical_reflection
    (e₁ e₂ : TropExpr) :
    normalize_ca e₁ = normalize_ca e₂ →
    ACEquiv e₁ e₂
```

together with

```lean
theorem ACEquiv.sound
    (h : ACEquiv e₁ e₂) :
    ∀ σ : Var → ℝ, eval e₁ σ = eval e₂ σ
```

and derive the computational corollary.

### 3. Reification correctness theorem

The tactic becomes real only when syntax from Lean terms is connected to `TropExpr`. You should define a meta-level reifier and prove a theorem about the quoted object-language interpretation. The theorem should have the shape:

```lean
theorem reify_correct
    (t : Q(ℝ)) (e : TropExpr) :
    reify t = some e →
    ∀ σ : Var → ℝ, eval e σ = denote σ t
```

If a direct theorem over `Q(ℝ)` is awkward, isolate a simpler theorem on the extracted AST for the supported fragment.

### 4. User-facing correctness theorem for the tactic kernel

The end-product theorem should support a tactic that closes goals by computation. A mathematically clean statement is:

```lean
theorem prove_tropical_eq_by_norm
    (e₁ e₂ : TropExpr) :
    decide (normalize_ca e₁ = normalize_ca e₂) = true →
    ∀ σ : Var → ℝ, eval e₁ σ = eval e₂ σ
```

This theorem is the kernel certificate behind a future `tropical` tactic.

---

## Suggested Lean 4 type signatures

Use these as targets, adapting names to your actual syntax/semantics definitions.

```lean
theorem normalize_ca_sound
    (e : TropExpr) (σ : Var → ℝ) :
    eval (normalize_ca e) σ = eval e σ
```

```lean
theorem normalize_ca_eq_implies_semantic_eq
    (e₁ e₂ : TropExpr)
    (h : normalize_ca e₁ = normalize_ca e₂) :
    ∀ σ : Var → ℝ, eval e₁ σ = eval e₂ σ
```

```lean
theorem normalize_ca_decide_sound
    [DecidableEq TropExpr]
    (e₁ e₂ : TropExpr)
    (h : decide (normalize_ca e₁ = normalize_ca e₂) = true) :
    ∀ σ : Var → ℝ, eval e₁ σ = eval e₂ σ
```

For the tactic-facing theorem over real expressions, if you encode environments via finite variable lists:

```lean
theorem tropical_goal_reflection
    (Γ : List Name) (e₁ e₂ : TropExpr)
    (σ : Name → ℝ)
    (hΓ₁ : respects_env Γ σ e₁)
    (hΓ₂ : respects_env Γ σ e₂)
    (h : normalize_ca e₁ = normalize_ca e₂) :
    eval e₁ σ = eval e₂ σ
```

And if you manage quotation-based reification:

```lean
theorem reified_tropical_eq_sound
    (lhs rhs : Q(ℝ))
    (el er : TropExpr)
    (hl : reify lhs = some el)
    (hr : reify rhs = some er)
    (h : normalize_ca el = normalize_ca er) :
    denoteQ lhs = denoteQ rhs
```

---

## Non-trivial demonstration theorems the tactic should solve

Do not stop at infrastructure. Prove new sample theorems that certify the tactic’s power. For example:

```lean
theorem tropical_assoc_comm_example (a b c d : ℝ) :
    min (a + b) (min (c + d) (a + b)) = min (min (d + c) (b + a)) (a + b)
```

```lean
theorem tropical_flatten_example (a b c d : ℝ) :
    min (min a b) (min c d) = min a (min d (min c b))
```

```lean
theorem tropical_duplicate_elim_example (a b c : ℝ) :
    min (a + b) (min (a + b) c) = min c (b + a)
```

These should be solved through the reflection pipeline, not by `linarith`, `simp`, or brute-force rewriting.

A more conceptually interesting theorem, if your syntax supports constants, is:

```lean
theorem tropical_semiring_AC_normal_form
    (a b c : ℝ) :
    min (a + (b + c)) ((c + b) + a) = a + (b + c)
```

This exhibits canonical collapse in the AC fragment.

---

## 2–3 proof strategy paths

### Strategy A: Reflection via existing `ACEquiv` completeness
**Most promising.**

1. Prove `normalize_ca_sound` by showing `e` is `ACEquiv` to `normalize_ca e`, then invoke semantic soundness of `ACEquiv`.
2. Prove that equality of normalized forms implies `ACEquiv e₁ e₂` by transitivity through the canonical form.
3. Package a decidable equality test on normalized syntax and derive the semantic equality theorem.

**Why this is best:** it maximally leverages the catalog’s existing completeness theorem instead of rebuilding semantic normalization from scratch. It also isolates the trusted kernel to a small theorem chain: normalization correctness + semantic soundness.

### Strategy B: Direct canonical-form semantics
1. Redefine `normalize_ca` output as a multiset- or sorted-list-based normal form.
2. Prove directly that evaluation is invariant under sorting, flattening, and duplicate normalization steps.
3. Show that equal canonical data structures imply semantic equality immediately.

**Why this is valuable:** it may produce cleaner executable code and better performance for `native_decide`. It also gives a more transparent extraction path toward a fast tactic.

**Risk:** more engineering burden if `normalize_ca` is already implemented differently.

### Strategy C: Meta-program first, theorem after
1. Implement `reify` and a prototype `elab "tropical" : tactic`.
2. Use the tactic on examples to discover the exact theorem interface needed.
3. Backfill the soundness theorem so the tactic emits proof terms rather than opaque `admit`-style closures.

**Why this helps:** Lean metaprogramming often clarifies the right representation.
**Risk:** easiest way to get trapped in infrastructure without proving the mathematical heart. Use only if Strategy A hits a mismatch between object-level syntax and quoted terms.

---

## How to build on existing catalog theorems

Use the existing results as anchors, not decorations.

1. **`tropical_plus_distributes_over_min`**
   - This theorem is not in the pure AC fragment, but it is crucial as a boundary marker.
   - Use it to articulate the exact scope of the tactic: the first version decides the AC fragment generated by `min` and `+`; a second-generation tactic could combine normalization with distributive rewriting.
   - In your writeup, explicitly distinguish:
     - **AC tropical normalization** from
     - **semiring tropical normalization**.

2. **`tropical_mirror_theorem`**
   - This is a trivial idempotence-like sanity check (`max a a = a`), but it suggests a future dual tactic for max-plus algebra.
   - Frame your work as building an automation core that can later be mirrored from min-plus to max-plus by changing the semantic dictionary.

3. **`tropical_fundamental_theorem`** and **`tropical_fundamental_theorem_of_arithmetic`**
   - These indicate that the library is already reaching toward structural tropical mathematics.
   - Your tactic should be positioned as the **automation substrate** needed to scale those formalizations: once tropical proofs reduce routine algebraic identities to reflection, higher-level theorems become dramatically easier to maintain and extend.

4. **`tropical_and_bound`**
   - This shows tropical reasoning already touches logical/constraint-style applications.
   - Use this to motivate future integration with certified inequality reasoning and tropical optimization.

---

## Deeper mathematical insight

The real mathematical content here is that the AC fragment of tropical algebra is a **free idempotent commutative algebraic theory modulo canonicalization data**. Reflection is not just a programming convenience; it is the formal counterpart of the universal-algebra fact that identities in a presented equational theory can often be decided by normal forms.

In classical proof automation:
- `ring` exploits canonical polynomial forms,
- `omega` exploits Presburger elimination,
- your `tropical` tactic would exploit **idempotent-commutative tropical normal forms**.

That places this work at a foundational point between:
- universal algebra,
- proof by reflection,
- semiring decision procedures,
- tropical geometry.

This is especially powerful because tropical mathematics is full of “obvious by rearranging mins and sums” steps that are currently expensive to formalize. A tactic here changes the economics of the whole field.

---

## Cross-domain connections

### 1. Proof by reflection / certified computation
This project sits squarely in the lineage of `ring`, `norm_num`, and verified SAT/SMT certificates. The tropical tactic can become a case study in **domain-specific theorem proving** for nonclassical algebraic structures.

### 2. Tropical geometry
Min-plus expressions define piecewise-linear functions and tropical hypersurfaces. Canonical equality checking is therefore a primitive for reasoning about equality of tropical polynomials in restricted fragments.

### 3. Optimization and shortest-path algebra
The min-plus semiring is the algebra of dynamic programming, shortest paths, Bellman operators, and scheduling. A reflection tactic for min-plus identities is a formal methods tool for verified optimization proofs.

### 4. Programming languages and semantics
Idempotent semirings appear in weighted automata, abstract interpretation, and cost semantics. Your tactic could become a backend for certifying algebraic rewrites in these domains.

### 5. Complexity and symbolic computation
This is a miniature symbolic computation engine inside Lean. It raises natural next questions about complexity bounds for normalization and certified extraction to efficient kernels.

---

## Breakthrough significance

If successful, this is not “one more tactic.” It would be:
- the first reusable **tropical normalization tactic** in Lean,
- a gateway to large-scale formal tropical geometry,
- a prototype for **semiring-specific reflective automation** beyond rings,
- an enabling technology for formalized dynamic programming and optimization.

The field-opening consequence is that tropical mathematics in Lean stops being bottlenecked by routine algebraic rewrites. That, in turn, makes ambitious formalizations feasible: tropical convexity, tropical linear algebra, tropicalized representation theory, and certified shortest-path algebra.

---

## Concrete deliverables

1. A semantic soundness theorem for `normalize_ca`.
2. A reflection theorem turning normalized syntactic equality into semantic equality.
3. A decidable equality / `native_decide` bridge for normalized forms.
4. A prototype `tropical` tactic or elaborator that solves a meaningful benchmark suite.
5. Several nontrivial example theorems proved *through the tactic*, not manually.

Minimize `sorry` especially in the theorem chain:
- normalization soundness,
- equality reflection,
- reification correctness.

If reification is the hardest part, it is acceptable to first complete a “quoted syntax input” version and then extend to actual term reification.

---

## Application keywords

`tropical algebra`, `proof by reflection`, `Lean 4 tactics`, `certified normalization`, `min-plus semiring`, `idempotent semiring`, `symbolic computation`, `decision procedures`, `formal tropical geometry`, `weighted automata`, `dynamic programming verification`, `shortest-path algebra`, `canonical forms`, `universal algebra`, `metaprogramming`

---

## Required final artifact

Produce a structured `FUTURE_DIRECTIONS.md` with **3–5 concrete, breakthrough-level next steps**. These must be specific and ambitious, for example:
1. extending from the AC fragment to distributivity and tropical polynomial normal forms,
2. dualizing the tactic to max-plus,
3. integrating with weighted automata or shortest-path verification,
4. building a certified tropical Gröbner-style simplifier,
5. connecting tropical normalization to piecewise-linear neural network verification.

Be bold: the point is not merely to automate existing lemmas, but to create the foundational engine that makes formal tropical mathematics scale.

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
