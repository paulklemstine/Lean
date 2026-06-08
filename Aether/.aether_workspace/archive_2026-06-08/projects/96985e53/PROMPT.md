Soli Deo Gloria

## Assignment: Direction 2 — Certified Reduction Orders (LPO, KBO) as the Engine of Autonomous Completion

**Mode:** prove

You should not treat this as a routine formalization of classical termination orders. The real target is to turn reduction orders into a *certified orientation machine* for equational reasoning: a theorem-level bridge from abstract order theory to executable completion. The breakthrough is not merely “LPO and KBO are well-founded,” but that these orders can be made into a reusable, verified interface that *automatically orients equations while preserving semantic correctness* across multiple algebraic theories.

Build directly on:

- `Pythagorean/ConcreteTermAlgebra.lean`
  - especially substitution/rewrite compatibility such as `rewrites_closed_under_subst`
- `Pythagorean/ConvergentRewriteSystems.lean`
  - especially `Terminating`, `Convergent`
- the lineage theorem `concrete_orient_preserves_equational_theory`

Your goal is to create a new formal layer: **certified simplification orders** on first-order terms, with LPO and KBO as flagship instances, and then use this layer to derive orientation-preservation and termination consequences for rewrite systems generated from equations.

---

## Core Vision

The missing ingredient in a truly automatic certified completion engine is not rewriting itself, but **provably correct orientation**. Once Aristotle formalizes a robust notion of reduction order and proves that LPO/KBO instantiate it, the system can take raw equations and autonomously produce sound directed rules. This opens the door to:

- certified Knuth–Bendix completion,
- verified termination analyzers,
- executable normalization tactics for algebraic structures,
- bridges to ordinal ranking functions, complexity analysis, and automated deduction.

This is significant because it transforms rewriting from a user-guided activity into a mathematically justified, machine-executable discovery pipeline.

---

## Precise Formal Targets

You should introduce at least one genuinely new concept not already in the catalog, for example:

- `ReductionOrder` on terms,
- `OrientableBy` for equations,
- `SymbolPrecedence` together with admissibility conditions,
- `KBOWeight` or `WeightAlgebra`,
- a certified `orientation_function` returning a directed rule together with preservation theorem.

A strong design is:

```lean
class ReductionOrder (α : Type u) where
  gt : α → α → Prop
  wf : WellFounded gt
  trans : Transitive gt
  subst_monotone :
    ∀ {s t : α}, gt s t → ∀ σ, gt (subst σ s) (subst σ t)
  context_monotone :
    ∀ {s t : α}, gt s t → ∀ C, gt (plug C s) (plug C t)
```

You may need to adapt `subst`, `plug`, and context types to the actual catalog definitions.

Then define concrete instances:

```lean
def LPO (prec : Symbol → Symbol → Prop) : Term Σ → Term Σ → Prop := ...
def KBO (w : Symbol → Nat) (prec : Symbol → Symbol → Prop) : Term Σ → Term Σ → Prop := ...
```

with finite-signature assumptions and admissibility hypotheses on `prec`.

---

## Theorem 1 — Well-foundedness of LPO on finite-signature first-order terms

### Mathematical statement
Let `Σ` be a finite first-order signature with a well-founded precedence on function symbols. Then the lexicographic path order induced by this precedence is a well-founded, transitive, substitution-stable, context-monotone strict order on terms.

This is the foundational theorem that turns LPO from a definition into a usable engine for termination proofs.

### Lean 4 target signature
A plausible target, to be adjusted to actual term/signature names in the catalog:

```lean
theorem lpo_wellFounded
    {Σ : Type u} [Fintype Σ]
    (arity : Σ → Nat)
    (prec : Σ → Σ → Prop)
    (hprec_wf : WellFounded prec)
    (hprec_trans : Transitive prec) :
    WellFounded (LPO arity prec : Term Σ → Term Σ → Prop)
```

and ideally the stronger package:

```lean
theorem lpo_isReductionOrder
    {Σ : Type u} [Fintype Σ]
    (arity : Σ → Nat)
    (prec : Σ → Σ → Prop)
    (hprec_wf : WellFounded prec)
    (hprec_trans : Transitive prec) :
    ReductionOrder (Term Σ)
```

where the `ReductionOrder` instance uses `LPO arity prec`.

### Why this is a breakthrough
This theorem converts classical rewriting folklore into a certified API for automatic orientation. Once proved, every equational theory presented over a finite signature inherits a canonical path to termination arguments.

### Proof strategy options

**Strategy A: Structural embedding into a lexicographic/multiset measure**
1. Define a size-height-rank measure on terms enriched by symbol precedence.
2. Prove that every `LPO s t` implies a strict decrease in a recursively defined accessibility predicate.
3. Use well-founded induction on the induced accessibility relation to obtain `WellFounded LPO`.

Why promising: most compatible with Lean if you want to avoid a full formalization of general multiset extensions at first.

**Strategy B: Formal multiset extension of precedence**
1. Define the multiset extension of a well-founded relation on terms/symbols.
2. Show the recursive clauses of LPO reduce either to subterm descent or to multiset/lexicographic descent on argument lists.
3. invoke well-foundedness of lexicographic and multiset extensions.

Why promising: mathematically canonical and reusable later for RPO, MPO, dependency pairs.

**Strategy C: Accessibility recursion directly on terms**
1. Define `Acc` for all proper subterms.
2. Prove by induction on term structure that each term is accessible for LPO.
3. In the critical recursive case, combine subterm property with precedence descent and lexicographic descent on argument vectors.

Why promising: often the cleanest “Lean-native” proof, though technically intricate.

**Most promising:** Strategy B if Mathlib support for multisets/lexicographic well-foundedness is sufficient; otherwise Strategy C is likely the best balance of rigor and implementation feasibility.

---

## Theorem 2 — Well-foundedness of KBO via weight interpretation and precedence

### Mathematical statement
Let `Σ` be a finite signature with admissible symbol weights and a well-founded precedence. Then the Knuth–Bendix order is a well-founded strict order on first-order terms. Moreover, if variable coefficients satisfy the standard KBO admissibility constraints, then KBO is substitution-stable and context-monotone.

### Lean 4 target signature
A plausible formal target:

```lean
structure KBOModel (Σ : Type u) where
  arity : Σ → Nat
  weight : Σ → Nat
  w0 : Nat
  prec : Σ → Σ → Prop
  prec_wf : WellFounded prec
  prec_trans : Transitive prec
  admissible : Prop
```

Then prove:

```lean
theorem kbo_wellFounded
    {Σ : Type u} [Fintype Σ]
    (M : KBOModel Σ) :
    WellFounded (KBO M : Term Σ → Term Σ → Prop)
```

and ideally:

```lean
theorem kbo_isReductionOrder
    {Σ : Type u} [Fintype Σ]
    (M : KBOModel Σ) :
    ReductionOrder (Term Σ)
```

### Why this matters
KBO is the practical workhorse of completion procedures. LPO gives conceptual elegance; KBO gives *automation power*. Proving KBO well-founded in this framework would make the library capable of orienting many algebraic presentations that LPO alone cannot handle cleanly.

### Proof strategy options

**Strategy A: Weight-first ranking**
1. Define total term weight recursively.
2. Show `KBO s t` implies either strict weight decrease or equal weight with lexicographic/precedence tie-break.
3. Prove well-foundedness by lexicographic composition of `Nat` weight with a well-founded tie-break relation.

Why promising: highly executable and naturally leads to a computable comparison algorithm.

**Strategy B: Ordinal-valued interpretation**
1. Interpret terms into a well-ordered ranking domain, e.g. lexicographic tuples or small ordinals coded in Lean.
2. Show KBO comparison implies strict ordinal descent.
3. Deduce well-foundedness from ordinal well-foundedness.

Why revolutionary: creates a bridge to ordinal arithmetic and proof-theoretic termination certificates.

**Strategy C: Reduction pair abstraction**
1. Define a generic reduction pair / simplification order interface.
2. Prove KBO satisfies each axiom separately: irreflexive, transitive, monotone, stable, well-founded.
3. Use a generic theorem that any simplification order yields termination for all finite rewrite systems decreasing under it.

Why promising: maximally reusable for future orders beyond KBO/LPO.

**Most promising:** Strategy A for initial success, with Strategy C layered on top so the result scales.

---

## Theorem 3 — Orientation preserves equational theory under certified reduction orders

### Mathematical statement
Let `>` be a reduction order on terms. If an equation `s ≈ t` is oriented as `s → t` because `s > t`, then replacing the equation by this rewrite rule preserves derivability in the generated equational theory, provided the orientation is applied within the framework already established in `concrete_orient_preserves_equational_theory`.

This is the theorem that upgrades order theory into semantic correctness.

### Lean 4 target signature
A plausible target:

```lean
theorem orient_by_reductionOrder_preserves_equational_theory
    {Σ : Type u}
    (gt : Term Σ → Term Σ → Prop)
    [ReductionOrder (Term Σ)]
    {s t : Term Σ} :
    gt s t →
    EquivGen ({(s, t)} : Set (Term Σ × Term Σ)) =
    EquivGen ({(s, t), (t, s)} : Set (Term Σ × Term Σ))
```

If the catalog already uses a more concrete relation for equations/rules, specialize to that exact notion. More realistically, you may prove a set-level theorem:

```lean
theorem orient_system_preserves_equational_theory
    {Σ : Type u}
    (E : Set (Term Σ × Term Σ))
    (R : Set (Term Σ × Term Σ))
    (horient : ∀ ⦃s t⦄, (s, t) ∈ E → ((s, t) ∈ R ∨ (t, s) ∈ R))
    (hcorrect : ∀ ⦃s t⦄, (s, t) ∈ E → EqClosure R s t) :
    EqClosure R = EqClosure E
```

and then instantiate `hcorrect` using your orientation theorem plus the catalog result.

### Why this is a breakthrough
This is the semantic certificate that justifies automatic rule generation. Without it, reduction orders are only heuristics. With it, they become mathematically trustworthy compilers from equations to rewrite systems.

### Proof strategy options

**Strategy A: Direct closure comparison**
1. Show every oriented rule is sound in the original equational theory because it came from an equation.
2. Show every original equation is derivable from the oriented system using symmetry where needed.
3. Conclude equality of generated equational closures by antisymmetry of set inclusion / extensionality.

**Strategy B: Build on `concrete_orient_preserves_equational_theory`**
1. Refactor the catalog theorem into a generic orientation lemma parametrized by an order.
2. Show LPO/KBO orientation satisfies the hypotheses.
3. Instantiate the generic theorem for each order.

**Strategy C: Categorical viewpoint**
1. Regard equations as generating a congruence and rewrite rules as generators of a reflexive-transitive closure inside that congruence.
2. Show orientation induces the same quotient object.
3. Translate back into the catalog’s concrete relation.

**Most promising:** Strategy B, because it reuses vetted infrastructure and avoids reproving closure machinery.

---

## Theorem 4 — Termination of finitely oriented systems decreasing under LPO/KBO

### Mathematical statement
If every rule `l → r` in a finite rewrite system `R` satisfies `l > r` for a well-founded reduction order `>`, then `R` is terminating. In particular, any finite system oriented by LPO or KBO is terminating.

This is the theorem that turns local order comparisons into global normalization.

### Lean 4 target signature
Likely something of the form:

```lean
theorem terminating_of_decreasing
    {Σ : Type u}
    (R : Set (Term Σ × Term Σ))
    (gt : Term Σ → Term Σ → Prop)
    (hwf : WellFounded gt)
    (hdecr : ∀ ⦃l r⦄, (l, r) ∈ R → gt l r) :
    Terminating R
```

Then derive:

```lean
theorem lpo_oriented_system_terminating
    {Σ : Type u} [Fintype Σ]
    (arity : Σ → Nat)
    (prec : Σ → Σ → Prop)
    (R : Set (Term Σ × Term Σ))
    (hdecr : ∀ ⦃l r⦄, (l, r) ∈ R → LPO arity prec l r) :
    Terminating R
```

and similarly for KBO.

### Why this matters
This theorem is the operational heart of completion and normalization. It closes the loop: compare terms → orient equations → obtain terminating computation.

### Proof strategy
1. Show one-step rewriting by `R` embeds into the reduction order `gt` using substitution and context monotonicity.
2. Prove that any infinite rewrite sequence would induce an infinite descending `gt`-chain.
3. Contradict `WellFounded gt`.

This proof should use nontrivial induction and closure reasoning, not trivial automation.

---

## New definitions to introduce

At least one of these should be genuinely new relative to the catalog:

1. **`ReductionOrder`**
   - a bundled structure for well-founded, transitive, substitution-stable, context-monotone strict orders.

2. **`OrientableBy`**
   - a predicate or function expressing that an equation can be canonically directed by an order:
   ```lean
   def OrientableBy (gt : α → α → Prop) (s t : α) : Prop := gt s t ∨ gt t s
   ```

3. **`CertifiedOrientation`**
   - a structure returning a directed rule plus proof that equational theory is preserved.

4. **`KBOModel`**
   - packages symbol weights, variable base weight, admissibility, and precedence.

5. **`TermComplexityVector`**
   - a cross-domain bridge object capturing weight, height, and symbol-rank, useful both for rewriting and complexity estimates.

---

## Cross-domain connection theorem

You are required to prove at least one theorem connecting rewriting to another domain. Do not make this decorative; make it mathematically meaningful.

### Recommended bridge: rewriting + ordinal/complexity theory

Prove that every LPO- or KBO-decreasing rewrite step strictly decreases a computable complexity measure, giving a certified ranking function into a well-founded domain.

### Candidate theorem
```lean
theorem kbo_decreases_weight_lex
    {Σ : Type u} [Fintype Σ]
    (M : KBOModel Σ) :
    ∃ μ : Term Σ → Nat × Lex (List Nat),
      ∀ {s t}, KBO M s t → Prod.Lex (· < ·) (Lex.instLT) (μ t) (μ s)
```

Or more simply:

```lean
theorem lpo_has_ranking_function
    {Σ : Type u} [Fintype Σ]
    (arity : Σ → Nat)
    (prec : Σ → Σ → Prop) :
    ∃ μ : Term Σ → Nat,
      ∀ {s t}, LPO arity prec s t → μ t < μ s
```

If a pure `Nat` ranking is too optimistic for full LPO, use a lexicographic tuple such as `(size, height, precedence profile)` or an accessibility/rank notion.

### Why this bridge matters
This links term rewriting to:
- **ordinal arithmetic**: reduction orders as descent in well-orders,
- **complexity theory**: ranking functions as certificates of bounded computation,
- **program verification**: automated termination arguments via certified measures.

This is exactly the kind of cross-pollination that can open new work on certified complexity bounds for normalization procedures.

---

## Computational deliverable: verified orientation algorithm

You must produce not only theorems but a verified computational method.

### Required algorithmic target
Implement a computable comparison/orientation procedure, at least for a tractable fragment:

```lean
def compareLPO? : Term Σ → Term Σ → Option Ordering := ...
def compareKBO? : Term Σ → Term Σ → Option Ordering := ...
def orientEquation? : Term Σ → Term Σ → Option (Term Σ × Term Σ) := ...
```

and prove soundness theorems such as:

```lean
theorem compareLPO?_sound_gt :
  compareLPO? prec s t = some Ordering.gt → LPO arity prec s t
```

```lean
theorem orientEquation?_sound :
  orientEquation? gt s t = some (l, r) →
  (l = s ∧ r = t ∨ l = t ∧ r = s) ∧ gt l r
```

If full completeness is too ambitious, prove soundness and partial completeness on a restricted class (e.g. bounded arity or precedence-total signatures).

This algorithm is the nucleus of a future completion engine.

---

## Conjecture with falsifiable computational prediction

You must state at least one conjecture that could fail under computation.

### Recommended conjecture
**Conjecture:** For every finite convergent equational presentation in the catalog examples whose equations are all orientable by admissible KBO, the KBO-oriented rule set obtained by greedy orientation is terminating and empirically confluent on all terms up to size `n = 8`.

This is falsifiable:
- a counterexample term pair with distinct normal forms disproves empirical confluence,
- a rewrite cycle disproves termination of the greedy orientation.

### Stronger variant
**Conjecture:** On signatures with at most one binary symbol and all unary symbols positive-weighted, KBO orientation succeeds on every equation set whose left-hand side has strictly larger variable multiplicity profile than the right-hand side.

This is also testable by random generation.

---

## Experimental protocol

Your `demo.py` should perform all of the following:

1. Generate 10,000 random term pairs over a signature with symbols of arities `0,1,2`.
2. Compare them with LPO/KBO and record:
   - proportion comparable,
   - transitivity checks on random triples,
   - time-to-decision statistics.
3. For free group, commutative monoid, and Boolean ring style presentations:
   - attempt orientation,
   - run bounded normalization on 1,000 random terms,
   - detect cycles or normalization failure,
   - report normal form stability statistics.

The verified Lean side should prove soundness of the comparison/orientation procedures; Python may be used for large-scale experimentation and visualization.

---

## Application keywords

Certified completion; reduction orders; lexicographic path order; Knuth–Bendix order; term rewriting; automated deduction; well-founded recursion; ordinal ranking functions; symbolic computation; termination certificates; equational reasoning; universal algebra; complexity of normalization; theorem proving; rewrite-based decision procedures.

---

## Implementation architecture

A strong file plan would be:

- `Pythagorean/ReductionOrders/Basic.lean`
  - `ReductionOrder`, `OrientableBy`, generic lemmas
- `Pythagorean/ReductionOrders/LPO.lean`
  - definition and core properties
- `Pythagorean/ReductionOrders/KBO.lean`
  - weight models, admissibility, well-foundedness
- `Pythagorean/ReductionOrders/Orientation.lean`
  - preservation of equational theory, termination of oriented systems
- `Pythagorean/ReductionOrders/Examples.lean`
  - free group / commutative monoid / Boolean ring examples

If you prefer a single file for this cycle, keep the abstractions clean enough to split later.

---

## Mandatory theorem checklist

Your file must contain at least 3 substantial theorems proved with deep tactics and multi-step reasoning, not trivial automation. A recommended minimum set is:

1. `lpo_wellFounded`
2. `kbo_wellFounded`
3. `orient_by_reductionOrder_preserves_equational_theory`
4. `terminating_of_decreasing`
5. one cross-domain ranking-function theorem

At least three of these must involve genuine induction, `rcases`, contradiction, or long `calc` chains.

---

## Deliverables

You must produce **all** of the following:

1. **Lean formalization** with minimized `sorry`, including:
   - new definitions,
   - at least 3 nontrivial theorems,
   - at least one cross-domain theorem,
   - one falsifiable conjecture encoded in comments or markdown with explicit computational test.

2. **A verified algorithm or computational method**
   - sound comparison/orientation procedure for LPO or KBO (full or fragmentary, but genuinely verified).

3. **`demo.py`**
   - interactive exploration of random term generation, LPO/KBO comparison, orientation experiments, bounded normalization statistics.

4. **`RESEARCH_PAPER.md`**
   - a standalone scientific paper explaining the definitions, theorems, proof ideas, significance, examples, limitations, and next steps.
   - Someone reading only this file must understand the discovery without seeing the code.

5. **`ARTICLE.md`**
   - Scientific American style.
   - Explain the mathematical ideas, why automatic orientation matters, and what new horizons it opens.
   - Do **not** focus on formal verification machinery.

6. **`FUTURE_DIRECTIONS.md`**
   - 3–5 original research directions.
   - Each direction must include:
     - “The key insight is ...”
     - “Why now?”
   - At least one direction must bridge to a distinctly different domain, such as proof theory, complexity theory, or symbolic physics.

---

## Final scientific ambition

Do not stop at “LPO/KBO are well-founded.” The true objective is to create the first layer of a **certified autonomous completion architecture**:
equations in, oriented terminating rules out, semantic correctness guaranteed.

If you succeed, the next cycle can attack:
- critical pair criteria under certified orientation,
- full Knuth–Bendix completion,
- dependency pairs,
- ordinal complexity bounds for normalization,
- rewrite-based decision procedures for algebraic theories.

This is not a library exercise. It is the mathematical infrastructure for turning rewriting theory into a verified discovery engine.

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
