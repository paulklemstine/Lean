## Assignment: Tactic engineer

Prove new, non-trivial theorems that make the syntax-to-semantics bridge *computationally executable* and *proof-producing*. Build on the catalog theorems, minimize `sorry`, and target a theorem that turns semantic soundness into a verified tactic kernel for a tropical/rewriting fragment.

### Mode
`prove`

### Research Direction
Implements the syntax-to-semantics bridge and verified tactic (Direction 4): certify that a syntactic rewriting procedure on a concrete expression language is semantics-preserving, terminating on a natural complexity measure, and therefore usable as the correctness core of an automated simplification tactic.

### Mathematical Framing
The breakthrough is not “another semantics-preservation lemma.” The real target is a **small reflective correctness theorem**: a syntax-level normalization/rewrite procedure whose output is guaranteed to denote the same semantic value, with proof architecture robust enough to power future certified automation in tropical algebra, neural semantics, and closure/logical duality. This opens a path from isolated bridge lemmas to a *verified compiler/tactic layer*.

Build directly on:
- `tropical_ultrametric_bounds_semantics`
  from `Bridges/HolographicProofRenormalization.lean`
- `tropical_neural_rewrite_shadow_preserves_semantics`
  from `Bridges/AlgebraMachineLearning/OperadicSemiringSemantics.lean`
- `closure_table_recovers_basis_and_spectrum`
  from `Bridges/AlgebraEMLLogic/ClosureStoneRealizationDuality.lean`
- `tropical_and_bound`
  from the tropical arithmetic/phylogenetics files

The conceptual leap: combine
1. **syntactic rewriting**
2. **semantic preservation**
3. **monotone tropical bounds**
4. **recoverability/duality structure**

into a theorem saying that normalization is not merely safe but extracts canonical semantic information.

---

## Primary Theorem Target

Define a small expression language for tropical formulas over `ℝ`, with constants, variables, tropical conjunction/min (`⊓`/`min`), and tropical addition (`+`). Then define:
- an evaluation function `eval`
- a one-step rewrite or normalization function `normalize`
- a complexity measure `size`

Target the following theorem:

### Precise theorem statement
For every environment `σ : ℕ → ℝ` and every tropical expression `e`, normalization preserves semantics and does not increase size:
\[
\forall \sigma\, e,\quad eval\ \sigma\ (normalize\ e)=eval\ \sigma\ e \;\land\; size (normalize\ e)\le size\ e.
\]

This is the minimum viable reflective theorem. If possible, strengthen to idempotence:
\[
\forall e,\quad normalize (normalize e)=normalize e.
\]

And if the normal form is designed canonically enough, prove extensional uniqueness on the chosen fragment:
\[
\forall e_1 e_2,\ normalize e_1 = normalize e_2 \to
\forall \sigma,\ eval\ \sigma\ e_1 = eval\ \sigma\ e_2.
\]

### Lean 4 type signature
A concrete target should look like:

```lean
inductive TropExpr where
  | const : ℝ → TropExpr
  | var   : ℕ → TropExpr
  | tmin  : TropExpr → TropExpr → TropExpr
  | add   : TropExpr → TropExpr → TropExpr
deriving DecidableEq, Repr

def eval (σ : ℕ → ℝ) : TropExpr → ℝ
  | .const r   => r
  | .var n     => σ n
  | .tmin a b  => min (eval σ a) (eval σ b)
  | .add a b   => eval σ a + eval σ b

def size : TropExpr → Nat
  | .const _   => 1
  | .var _     => 1
  | .tmin a b  => size a + size b + 1
  | .add a b   => size a + size b + 1

def normalize : TropExpr → TropExpr := ...

theorem normalize_preserves_semantics_and_size
    (σ : ℕ → ℝ) (e : TropExpr) :
    eval σ (normalize e) = eval σ e ∧ size (normalize e) ≤ size e := by
  ...

theorem normalize_idempotent
    (e : TropExpr) :
    normalize (normalize e) = normalize e := by
  ...
```

If full normalization is too ambitious on a first pass, prove a one-step rewrite soundness theorem:

```lean
def RewriteStep := TropExpr → TropExpr

theorem rewrite_step_sound
    (σ : ℕ → ℝ) (e : TropExpr) :
    eval σ (rewriteStep e) = eval σ e := by
  ...
```

and then lift it to an iterated normalizer.

---

## Stronger Breakthrough Variant

If you can define a boolean checker `isNormalized : TropExpr → Bool` and a certified normalizer returning a normal form together with proof obligations, aim for:

```lean
theorem normalize_certified
    (σ : ℕ → ℝ) (e : TropExpr) :
    isNormalized (normalize e) = true ∧
    eval σ (normalize e) = eval σ e := by
  ...
```

This would be the real “verified tactic kernel” theorem: executable normalization + proof of soundness + recognizability of the output class.

---

## Why this is a breakthrough

The bridge theorems in the catalog already say that certain semantic shadows are preserved. But a field-opening result is to package this into a **formal reflective infrastructure**:
- syntax transformed algorithmically,
- semantics preserved by theorem,
- output shape certified,
- complexity controlled.

That is the seed of:
- verified simplifiers for tropical optimization,
- proof-producing normalizers for neural/tropical semantics,
- trusted symbolic front-ends for algebraic ML,
- semantics-aware rewriting in closure logic and duality systems.

This moves the project from “proved bridge lemmas” to “constructed a new theorem-proving technology.”

---

## Suggested definitions and rewrite rules

Use only semantically safe rules that are easy to certify over `ℝ`:
- recursive normalization of children
- constant folding:
  - `tmin (const a) (const b) ↦ const (min a b)`
  - `add (const a) (const b) ↦ const (a + b)`
- optional idempotence rule:
  - `tmin e e ↦ e`
- optional commutative canonicalization only if you can define an ordering on expressions
- optional neutral-element rules if you introduce `∞`, but avoid this unless you switch to `WithTop ℝ`

A highly viable first theorem is obtained without commutativity or associativity normalization; just recursive constant folding plus `tmin e e ↦ e` already yields nontrivial semantic and structural content.

---

## Proof Strategy A: Structural induction with semantic local lemmas
Most promising.

1. **Define local rewrite soundness lemmas**
   Prove each rewrite rule preserves `eval`. For example:
   ```lean
   theorem eval_tmin_const_const (σ : ℕ → ℝ) (a b : ℝ) :
       eval σ (.tmin (.const a) (.const b)) = eval σ (.const (min a b)) := by
     simp [eval]
   ```
   and similarly for addition and idempotence.

2. **Induct on expression structure**
   In the `tmin` and `add` cases, normalize children first, use IH to rewrite their semantics, then discharge the top-level case by case-splitting on normalized children.

3. **Pair semantic preservation with size monotonicity**
   Prove size decreases or stays bounded by direct arithmetic on `Nat`. If using `tmin e e ↦ e`, show strict decrease in that branch. This can later support termination of repeated rewriting.

Why this is promising: it is maximally compatible with Lean 4, requires only elementary Mathlib facts, and gives a reusable library of sound rewrite lemmas.

---

## Proof Strategy B: Abstract rewrite relation + congruence closure
More elegant, more extensible.

1. Define an inductive relation `Step : TropExpr → TropExpr → Prop` encoding one-step rewrites.
2. Prove **soundness of one-step reduction**:
   ```lean
   theorem step_sound (σ) : Step e e' → eval σ e' = eval σ e
   ```
3. Define reflexive-transitive closure `ReflTransGen Step` and prove semantic invariance along reductions.
4. Show `normalize e` is reachable from `e`.

This approach is better if you want a future verified tactic with trace certificates: the tactic can return a reduction path and Lean checks it.

---

## Proof Strategy C: Semantics as a homomorphism into an idempotent semiring shadow
Most visionary, but higher risk.

1. Interpret `TropExpr` as the free syntax on generators for the tropical semiring fragment.
2. Show `eval σ` is a semiring-like homomorphism into the min-plus algebra over `ℝ`.
3. Prove normalization computes canonical representatives modulo the equations of the fragment.

This could connect directly to `tropical_neural_rewrite_shadow_preserves_semantics`, making the normalization theorem an instance of a broader operadic or algebraic semantics-preservation principle. Pursue this only if the existing catalog file already contains reusable abstraction.

---

## How to use the catalog theorems as building blocks

### 1. `tropical_neural_rewrite_shadow_preserves_semantics`
Use this as the conceptual anchor: your normalization theorem should be presented as a concrete, executable instance of rewrite-shadow semantic preservation. If the theorem is abstract enough, instantiate its rewriting notion on `TropExpr`. If not, mirror its proof pattern: “local rewrite semantics + compositionality = global preservation.”

### 2. `tropical_ultrametric_bounds_semantics`
Exploit this to derive a **secondary corollary**: normalization preserves not only exact semantics but also any certified ultrametric/tropical bound already attached to semantics. In other words, if that theorem gives a semantic bound `B e`, prove:
```lean
eval σ (normalize e) = eval σ e
```
then transport the bound theorem across the equality. This turns rewriting into a safe preprocessing step for certified bounds.

### 3. `tropical_and_bound`
This is small but useful. Any theorem involving `min` can use it for monotonicity/bound side-lemmas. For example, if you define a “semantic upper bound” recursively, `min`-nodes automatically inherit upper bounds via `min a b ≤ a`.

### 4. `closure_table_recovers_basis_and_spectrum`
This is the deepest cross-domain connection. The normalization theorem can be framed as a syntactic closure operation whose output recovers canonical semantic data, analogous to closure data recovering basis/spectrum. If you can define a normal-form predicate and prove idempotence, extensiveness/contractiveness-style properties, you have the beginnings of a closure operator viewpoint on normalization.

---

## Secondary theorem targets

After the primary theorem, prove at least one of these:

### A. Idempotence of normalization
```lean
theorem normalize_idempotent
    (e : TropExpr) :
    normalize (normalize e) = normalize e := by
  ...
```
This upgrades normalization from a procedure to a closure/canonicalization operator.

### B. Soundness of a proof-producing simplifier
Define:
```lean
def simplifyCert (e : TropExpr) : TropExpr × Prop := ...
```
or a structure carrying output plus proof of semantic equality. Then prove projection soundness.

### C. Semantic bounds preserved by normalization
For any recursively defined upper bound `ub : TropExpr → ℝ`, prove:
```lean
theorem normalize_preserves_upper_bound
    (σ : ℕ → ℝ) (e : TropExpr)
    (h : eval σ e ≤ ub e) :
    eval σ (normalize e) ≤ ub e := by
  ...
```
or define `ub` on normalized forms and transport via semantic equality.

### D. Finset semantics variant
To connect with concrete combinatorics, define expressions over `Finset ℕ` supports or finite variable contexts and prove the same theorems in a finitely supported setting. This is especially relevant if you later want reflective tactics over concrete goals.

---

## Cross-domain connections to emphasize

1. **Verified tactics / reflection**
   This theorem is a miniature trusted kernel for symbolic simplification. It is directly relevant to theorem proving and proof-producing automation.

2. **Tropical geometry / idempotent analysis**
   Normal forms for min-plus expressions are tropical polynomials in embryonic form. Certified normalization is a foundational step toward tropical elimination and certified piecewise-linear reasoning.

3. **Neural network semantics**
   Min-plus and piecewise-linear rewrites appear as shadows of ReLU/max-plus computations. A certified simplifier can become a preprocessing engine for robustness and equivalence proofs.

4. **Closure systems / Stone-style duality**
   If `normalize` is idempotent and semantics-determining, it behaves like a closure/canonical representative operator. This links symbolic rewriting to algebraic logic and spectral reconstruction.

5. **Program verification / compiler correctness**
   `normalize_preserves_semantics` is a toy but real compiler-correctness theorem. Future work can scale this to domain-specific compilers for tropical or neural expressions.

---

## Concrete implementation advice in Lean 4

- Keep the datatype minimal.
- Use `simp [eval, normalize]` aggressively after recursive normalization.
- For `size` inequalities, `omega` may help if imported, but basic `simp_arith` or `linarith` is often enough for small `Nat` goals after rewriting.
- If proving idempotence, design `normalize` so recursive calls normalize children first and top-level simplification is deterministic.
- Derive `DecidableEq` on syntax so `tmin e e ↦ e` can be implemented by checking equality of normalized children.

A practical normalization skeleton:

```lean
def normalize : TropExpr → TropExpr
  | .const r => .const r
  | .var n => .var n
  | .add a b =>
      let a' := normalize a
      let b' := normalize b
      match a', b' with
      | .const x, .const y => .const (x + y)
      | _, _ => .add a' b'
  | .tmin a b =>
      let a' := normalize a
      let b' := normalize b
      if h : a' = b' then a'
      else
        match a', b' with
        | .const x, .const y => .const (min x y)
        | _, _ => .tmin a' b'
```

This gives a genuinely nontrivial idempotent normalizer.

---

## Deliverables

1. A Lean file implementing `TropExpr`, `eval`, `size`, `normalize`.
2. Proof of
   - `normalize_preserves_semantics_and_size`
   - `normalize_idempotent`
3. At least one secondary theorem from the list above.
4. Minimize `sorry`; if any remain, isolate them to a tiny local arithmetic or helper lemma.
5. Create `FUTURE_DIRECTIONS.md` with 3–5 concrete next steps.

---

## Required `FUTURE_DIRECTIONS.md`

This is critical. Include 3–5 specific theorem-level next steps, each with:
- precise statement,
- proof strategy,
- cross-domain payoff.

Strong candidate next steps:
1. **Confluence/canonical form theorem** for a richer commutative-associative tropical syntax.
2. **Certified decision procedure** for semantic equality on a finite tropical fragment.
3. **Normalization with bounds preservation** using `tropical_ultrametric_bounds_semantics`.
4. **Reflection tactic**: reify Lean goals about tropical expressions and discharge them by normalization.
5. **Closure-operator abstraction** connecting `normalize_idempotent` to algebraic closure systems and `closure_table_recovers_basis_and_spectrum`.

---

## Application keywords
verified tactics, reflection, compiler correctness, tropical algebra, idempotent semirings, neural semantics, rewrite systems, closure operators, symbolic AI, proof-producing normalization, ultrametric bounds, algebraic logic, formal methods, semantic preservation

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
