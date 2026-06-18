## Assignment: Tropical Curry–Howard: Proofs as Min-Plus Programs

Mode: **prove**

Prove genuinely new theorems that make the slogan

> **proofs are min-plus programs, propositions are tropical types**

mathematically precise in Lean 4.

Do not settle for analogy. Build a formal reduction system, a semantic cost interpretation, and a canonical normalization theorem whose mechanism is specifically tropical: **idempotence of `min` collapses proof redundancy into canonical normal forms**.

Minimize `sorry`. If a full grand theorem is too large in one pass, first prove the structural core cleanly and package the next layer in `FUTURE_DIRECTIONS.md`.

---

## Research Direction

Create a formal tropical proof calculus in which:

- conjunction-like structure is interpreted by `min`,
- sequential composition / resource accumulation is interpreted by tropical addition,
- proofs carry a **cost semantics**,
- cut elimination is a reduction relation on proof terms,
- normalization computes the least-cost representative of a proof.

Then prove that the tropical algebraic laws force a canonical normalization discipline:

1. **strong normalization** of cut reduction,
2. **local confluence / diamond-style commutation** for the primitive tropical reductions,
3. **global confluence** via Newman’s lemma using the existing `strongly_normalizing`,
4. **canonicality**: normal forms are unique up to the idempotent collapse induced by `min`.

This is not a minor logic exercise. If formalized correctly, it opens a new bridge between:

- proof theory,
- idempotent semiring semantics,
- shortest-path / dynamic programming algorithms,
- verification of cost-sensitive programs,
- tropical geometry as a semantics of normalization.

---

## Mathematical Framing

The central breakthrough is to treat proof normalization as a **min-plus optimization process** rather than a mere syntactic simplification.

Classically, cut elimination removes detours.
Here, tropical cut elimination should do more: it should compute the **optimal detour-free proof**, because duplicate subproofs collapse under `min` and sequential proof cost accumulates under `+`.

This turns normalization into a certified optimization algorithm.

The decisive theorem to aim for is:

> In a tropical proof calculus, every proof reduces to a unique canonical normal form, and the cost of that normal form is the minimum cost among all reduction-equivalent proofs.

That statement is simultaneously proof-theoretic, algebraic, and algorithmic.

---

## Precise Formal Targets

You will likely need to define a small inductive syntax in a new file such as:

- `Logic/TropicalCurryHowardCanonical.lean`

Use concrete types first, preferably `Nat` for cost semantics. If needed, later generalize to `ℝ≥0∞` or tropical semirings.

### Core syntax suggestion

Define a proof/program syntax with one atomic proposition layer stripped away, so the first theorem is about normalization mechanics rather than full dependent type theory.

A minimal object language could be:

```lean
inductive TropProof where
  | atom : Nat → TropProof
  | cut  : TropProof → TropProof → TropProof
  | tmin : TropProof → TropProof → TropProof
  | tplus : TropProof → TropProof → TropProof
deriving DecidableEq, Repr
```

Define a cost semantics:

```lean
def cost : TropProof → Nat
  | .atom n => n
  | .cut p q => cost p + cost q
  | .tmin p q => min (cost p) (cost q)
  | .tplus p q => cost p + cost q
```

Define a one-step reduction relation `TropStep` encoding tropical normalization / cut elimination, e.g. distributive pushing and idempotent collapse. A possible initial system:

```lean
inductive TropStep : TropProof → TropProof → Prop where
  | cut_tmin_left  : TropStep (.cut (.tmin p q) r) (.tmin (.cut p r) (.cut q r))
  | cut_tmin_right : TropStep (.cut p (.tmin q r)) (.tmin (.cut p q) (.cut p r))
  | tplus_tmin_left  : TropStep (.tplus (.tmin p q) r) (.tmin (.tplus p r) (.tplus q r))
  | tplus_tmin_right : TropStep (.tplus p (.tmin q r)) (.tmin (.tplus p q) (.tplus p r))
  | min_idem : TropStep (.tmin p p) p
  | ctx_cut_left  : TropStep p q → TropStep (.cut p r) (.cut q r)
  | ctx_cut_right : TropStep p q → TropStep (.cut r p) (.cut r q)
  | ctx_min_left  : TropStep p q → TropStep (.tmin p r) (.tmin q r)
  | ctx_min_right : TropStep p q → TropStep (.tmin r p) (.tmin r q)
  | ctx_plus_left : TropStep p q → TropStep (.tplus p r) (.tplus q r)
  | ctx_plus_right : TropStep p q → TropStep (.tplus r p) (.tplus r q)
```

You may refine this once the critical pair analysis becomes clearer.

---

## Exact Theorem Statements to Target

### Theorem 1: Reduction preserves tropical cost

This is the first semantic sanity check and should be fully formalized.

```lean
theorem step_preserves_cost :
  ∀ {p q : TropProof}, TropStep p q → cost q = cost p
```

Why it matters:
- it proves normalization is semantics-preserving,
- it uses the catalog distributivity theorem in a nontrivial proof-theoretic setting,
- it is the bridge from syntax to optimization semantics.

Use:
- `min_idempotent`
- `tropical_plus_distributes_over_min`

---

### Theorem 2: Normal forms are idempotent-free and cut-distributed

Define:

```lean
def Normal : TropProof → Prop := fun p => ¬ ∃ q, TropStep p q
```

Then prove structural invariants of normal forms. For example:

```lean
theorem normal_no_min_self :
  ∀ {p : TropProof}, Normal p → ∀ q, p ≠ TropProof.tmin q q
```

and more substantially, after defining a recursive normalizer:

```lean
def normalize : TropProof → TropProof := ...
```

prove:

```lean
theorem normalize_normal : ∀ p, Normal (normalize p)
```

and

```lean
theorem normalize_cost :
  ∀ p, cost (normalize p) = cost p
```

This upgrades abstract normalization into an executable certified algorithm.

---

### Theorem 3: Local confluence for primitive tropical reductions

State a one-step diamond property for a primitive relation if full `TropStep` is too contextual. A workable decomposition is to define `PrimStep` without context closure, prove local diamond there, and then lift.

```lean
theorem primstep_local_diamond :
  ∀ {p q r : TropProof},
    PrimStep p q → PrimStep p r →
    ∃ s, ReflTransGen PrimStep q s ∧ ReflTransGen PrimStep r s
```

This is the heart of the project. It is where tropical algebra, not generic rewriting folklore, must do the work.

The key critical pairs should resolve because:
- `min` is idempotent,
- `+` distributes over `min`,
- duplicate branches collapse canonically.

---

### Theorem 4: Global confluence from strong normalization

Using the existing theorem

- `strongly_normalizing : WellFounded Reduces`

or an adapted relation, prove a Newman-style result for your tropical reduction system:

```lean
theorem tropical_confluent :
  ChurchRosser TropStep
```

or, more concretely,

```lean
theorem tropical_confluence :
  ∀ {p q r : TropProof},
    ReflTransGen TropStep p q →
    ReflTransGen TropStep p r →
    ∃ s, ReflTransGen TropStep q s ∧ ReflTransGen TropStep r s
```

If the catalog’s `strongly_normalizing` is for a pre-existing `Reduces`, either:
- instantiate your `TropStep` as that relation,
- or prove your relation is a subrelation / image of `Reduces`.

---

### Theorem 5: Canonical normal form uniqueness

This is the flagship theorem.

```lean
theorem normalize_unique :
  ∀ p q,
    Normal p → Normal q →
    ReflTransGen TropStep p q →
    p = q
```

or algorithmically:

```lean
theorem normalize_complete :
  ∀ p q,
    ReflTransGen TropStep p q →
    normalize p = normalize q
```

This is the true Curry–Howard tropical statement:
**proof identity is computed by optimization and idempotent collapse**.

---

### Theorem 6: Minimal-cost characterization of normalization

Define convertibility:

```lean
def Convertible (p q : TropProof) : Prop :=
  ∃ s, ReflTransGen TropStep p s ∧ ReflTransGen TropStep q s
```

Then prove:

```lean
theorem normalize_is_minimal :
  ∀ p q,
    Convertible p q →
    cost (normalize p) ≤ cost q
```

If exact minimality among all convertible terms is too strong because `step_preserves_cost` gives equality rather than strict decrease, refine the semantics:

- syntactic size strictly decreases,
- cost remains invariant,
- among normal forms there is a unique representative.

Then the theorem becomes:

```lean
theorem normalize_canonical :
  ∀ p q,
    Convertible p q →
    Normal q →
    normalize p = q
```

This is often the cleaner formal target.

---

## Lean 4 Type Signature Suggestions

Here are compact signatures Aristotle can directly target.

```lean
inductive TropProof where
  | atom : Nat → TropProof
  | cut : TropProof → TropProof → TropProof
  | tmin : TropProof → TropProof → TropProof
  | tplus : TropProof → TropProof → TropProof
deriving DecidableEq, Repr

def cost : TropProof → Nat := ...

inductive PrimStep : TropProof → TropProof → Prop := ...
inductive TropStep : TropProof → TropProof → Prop := ...

def Normal (p : TropProof) : Prop := ¬ ∃ q, TropStep p q

def Convertible (p q : TropProof) : Prop :=
  ∃ s, Relation.ReflTransGen TropStep p s ∧ Relation.ReflTransGen TropStep q s

def normalize : TropProof → TropProof := ...

theorem step_preserves_cost :
  ∀ {p q : TropProof}, TropStep p q → cost q = cost p := by

theorem normalize_normal :
  ∀ p : TropProof, Normal (normalize p) := by

theorem normalize_cost :
  ∀ p : TropProof, cost (normalize p) = cost p := by

theorem primstep_local_diamond :
  ∀ {p q r : TropProof},
    PrimStep p q → PrimStep p r →
    ∃ s,
      Relation.ReflTransGen PrimStep q s ∧
      Relation.ReflTransGen PrimStep r s := by

theorem tropical_confluence :
  ∀ {p q r : TropProof},
    Relation.ReflTransGen TropStep p q →
    Relation.ReflTransGen TropStep p r →
    ∃ s,
      Relation.ReflTransGen TropStep q s ∧
      Relation.ReflTransGen TropStep r s := by

theorem normalize_unique :
  ∀ {p q : TropProof},
    Normal p → Normal q →
    Relation.ReflTransGen TropStep p q →
    p = q := by

theorem normalize_complete :
  ∀ p q : TropProof,
    Relation.ReflTransGen TropStep p q →
    normalize p = normalize q := by
```

If `ChurchRosser` is already available in Mathlib for your relation, use it; otherwise, the explicit confluence statement is safer.

---

## How to Build on the Catalog Theorems

### 1. `min_idempotent`
File: `Logic/IdempotentProofComplexity.lean`

Use it as the algebraic engine for duplicate-proof collapse. Do not merely cite it; make it operational:
- in `step_preserves_cost`, the `min_idem` reduction should reduce to this theorem,
- in critical pair analysis, use idempotence to show two branches that differ only by duplicate subproofs rejoin.

This is the theorem that turns tropical logic from “weighted logic” into a canonical logic.

---

### 2. `strongly_normalizing`
File: `Logic/TropicalCurryHoward.lean`

This is your route to global confluence via Newman’s lemma.
Possible uses:
- instantiate your reduction relation to match the existing `Reduces`,
- or define a measure from `TropProof` into a well-founded order and prove your `TropStep` is included in a strongly normalizing relation already certified.

Do not re-prove strong normalization from scratch unless the existing theorem is unusable.

---

### 3. `tropical_plus_distributes_over_min`
Files:
- `Bridges/AlgebraTropicalCryptography/TropicalScatteringOneWayDuality.lean`
- `Bridges/AlgebraTropicalGeometry/TropicalRadonGraphDuality.lean`
- `Bridges/MinPlusVerificationCore.lean`

This is the key semantic proof ingredient for distributive cut-pushing and program normalization:
- `cost (tplus (tmin p q) r) = min (cost (tplus p r)) (cost (tplus q r))`
- similarly for `cut`.

The `Nat` version is likely easiest for your initial syntax. The `ℝ` versions suggest a later extension to continuous cost semantics or tropical analytic semantics.

---

## Proof Strategy Architecture

### Strategy A: Rewriting-theoretic core first, then semantic layer
Most promising.

1. Define a small primitive reduction system `PrimStep` with only:
   - distributive push rules,
   - idempotent collapse.
2. Prove local diamond by explicit critical pair analysis.
   - The only genuinely nontrivial overlaps should involve distributivity against idempotence and nested distributivity.
3. Use `strongly_normalizing` or a custom measure to derive global confluence.
4. Define `normalize` by well-founded recursion or by choosing the unique normal form.
5. Add cost semantics and prove preservation / canonicality.

Why this is strongest:
- it isolates the proof-theoretic novelty,
- it avoids getting stuck on semantics before the rewriting system is coherent,
- it gives a clean path to Newman’s lemma.

---

### Strategy B: Semantic normalization by evaluation into a canonical min-plus form
Potentially elegant, especially if rewriting proofs get messy.

1. Define a denotation of `TropProof` into a canonical algebra of tropical polynomials / finite multisets modulo idempotence.
2. Define `normalize` by reification from denotation.
3. Prove soundness:
   - one-step reductions preserve denotation,
   - reification yields normal forms.
4. Prove completeness:
   - every proof reduces to the reified denotation,
   - equal denotations give equal normal forms.

Why it may work:
- canonical forms are often easier semantically than syntactically,
- idempotence is naturally quotiented in denotational semantics.

Why it is riskier:
- reification machinery in Lean may be heavier than direct rewriting,
- quotient-style canonical forms can create engineering overhead.

---

### Strategy C: Dynamic-programming interpretation of proof normalization
Most visionary, but probably second-phase unless the syntax is very small.

1. Interpret each proof term as a DAG of alternative derivations.
2. Show normalization computes shortest paths in that DAG:
   - `min` = choice,
   - `+` = path concatenation.
3. Use shortest-path uniqueness/canonicality arguments to derive proof canonicality.
4. Reconnect the syntactic relation to graph-theoretic optimization.

Why it matters:
- this would make Curry–Howard tropical logic immediately relevant to certified optimization and verification,
- it cross-pollinates with algorithms in a way most proof theory never does.

Why it is probably phase two:
- the graph encoding is conceptually deep but may slow the first formal breakthrough.

---

## Recommended Execution Plan

1. **Define the syntax and primitive reductions.**
2. **Prove `step_preserves_cost`.**
3. **Prove local confluence for `PrimStep`.**
4. **Import or adapt strong normalization.**
5. **Derive global confluence.**
6. **Define `normalize` and prove uniqueness/canonicality.**
7. **Add one cross-domain theorem showing this normalization computes an optimization principle.**

This sequence maximizes the chance of a fully formalized, nontrivial result with minimal `sorry`.

---

## Cross-Domain Connections You Must Exploit

### 1. Proof theory × shortest-path algorithms
The semantics of tropical proofs is exactly the algebra of path optimization:
- `min` = branching choice,
- `+` = concatenation of costs.

A normalized proof is a shortest derivation certificate.
This suggests applications to:
- proof search,
- certified planning,
- optimal tactic synthesis.

### 2. Logic × idempotent semirings
Your normalization theorem is a logical analogue of canonicalization in idempotent semiring algebra.
This opens the door to:
- weighted type systems,
- resource-aware theorem proving,
- semiring-enriched proof assistants.

### 3. Tropical geometry × normalization spaces
Normal forms may be viewed as cells in a tropical polyhedral decomposition of proof space.
Different syntactic derivations collapse to a single tropical vertex/cell representative.
This is science-fiction-level fertile ground:
- proof moduli spaces,
- tropical proof invariants,
- geometric complexity of normalization.

### 4. Verification × cryptography
The existing bridge theorems in tropical cryptography suggest that min-plus normalization may encode optimal adversarial strategies or attack traces.
A tropical Curry–Howard theorem could therefore become a logic of:
- attack-cost certificates,
- optimal witness extraction,
- proof-carrying security bounds.

### 5. Programming languages × differentiable / neural reasoning
Min-plus circuits are close relatives of dynamic programming networks and tropical neural models.
A canonical proof normalizer here could become a certified backend for:
- neuro-symbolic shortest-proof search,
- cost-aware synthesis,
- tropical abstract interpretation.

---

## Application Keywords

Include these explicitly in comments, theorem docs, or `ARTICLE.md`:

- tropical logic
- Curry–Howard correspondence
- min-plus algebra
- idempotent semiring
- cut elimination
- normalization by evaluation
- confluence
- strong normalization
- canonical forms
- shortest-path semantics
- dynamic programming
- certified optimization
- proof complexity
- tropical geometry
- program verification
- weighted proof systems
- semiring semantics
- proof search
- resource-sensitive logic

---

## Nontrivial Stretch Theorem

If the core system lands cleanly, prove one bridge theorem that makes outsiders pay attention.

For example, define a finite graph path language and encode paths as tropical proofs. Then prove:

```lean
theorem graph_path_normalization_optimal :
  ∀ (G : SimpleGraph α) [Fintype α] [DecidableEq α]
    (w : α → α → Nat) (s t : α),
    -- after defining an encoding `encodePaths G w s t : TropProof`
    cost (normalize (encodePaths G w s t)) =
      shortestPathCost G w s t
```

Even a restricted DAG version would be spectacular.
That theorem would convert your proof normalizer into a certified shortest-path solver under Curry–Howard.

---

## Deliverables

1. Lean file formalizing the tropical proof syntax, reduction, and canonical normalization.
2. Lean proofs of as many of the target theorems above as possible.
3. Minimal `sorry`.
4. `FUTURE_DIRECTIONS.md` with **3–5 concrete breakthrough next steps**.

---

## Required FUTURE_DIRECTIONS.md

You must produce `FUTURE_DIRECTIONS.md` with 3–5 specific, technically credible next steps, such as:

1. Extend from `Nat` costs to `ℝ≥0∞` and prove tropical normalization for infinite-cost / unreachable proofs.
2. Formalize a sequent calculus or simply typed lambda calculus whose cut elimination maps into the current min-plus core.
3. Prove a graph-theoretic representation theorem: tropical proofs are exactly finite acyclic dynamic programs.
4. Develop a tropical proof complexity invariant measuring the polyhedral dimension of proof search space.
5. Connect canonical tropical normal forms to weighted automata or Viterbi-style decoding.

Make these concrete, not aspirational.

---

## Tactical Advice

- Start small: one syntax, one reduction system, one canonical theorem.
- Prefer `Nat` over `ℝ` initially to keep rewriting and well-foundedness manageable.
- Use `Relation.ReflTransGen` aggressively.
- If proving confluence for full contextual closure is painful, prove it for `PrimStep`, then lift carefully.
- If executable `normalize` is hard, first prove existence and uniqueness of normal forms noncomputably; computation can come next.
- Where direct equality proofs stall, prove both sides equal to `cost p` or use distributivity lemmas to normalize arithmetic expressions.

---

## Final Objective

Produce a Lean development in which tropical logic is not metaphorical but mechanized:

> **cut elimination = min-plus normalization = canonical optimization of proofs**

If you can establish even the small-model version of this statement with clean formal proofs, you will have created a new research program: **idempotent proof theory**.

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

Research domain: Logic
Research mode: prove
