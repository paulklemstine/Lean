Soli Deo Gloria

## Assignment: Direction 1 — Contractivity of Evaluation Strategies

**Mode:** `prove`

Build a new quantitative dynamics theory for simply-typed λ-calculus: not merely that evaluation is nonexpansive, but that a canonical operational strategy creates a genuine dissipative flow on β-equivalence classes. The goal is to turn normalization into a metric dynamical system and make `eqPathDist` the first bridge between rewriting theory, Banach fixed-point phenomena, and semantics of program optimization.

This is not an incremental extension of catalog nonexpansiveness lemmas. The breakthrough target is to isolate a structural subclass of terms and/or a refined distance for which **leftmost-outermost evaluation is provably strictly contractive**, then use that to derive convergence rates, uniqueness of normal forms as metric attractors, and an executable contraction certificate.

You should be bold but mathematically disciplined: if the full conjecture is false, extract the strongest true theorem and formally exhibit the obstruction. A sharp impossibility theorem plus a repaired contraction theorem is a field-opening result.

---

## Core Breakthrough Objective

The original conjecture is:

> For simply-typed λ-terms, one-step leftmost-outermost evaluation is strictly contractive with respect to `eqPathDist`: there exists `c < 1` such that for all β-equivalent simply-typed terms `t, u` with `eqPathDist t u > 0`,
> \[
> \mathrm{eqPathDist}(\mathrm{eval₁}(t), \mathrm{eval₁}(u)) \le c \cdot \mathrm{eqPathDist}(t,u).
> \]

This is revolutionary because, if true even in a calibrated form, it upgrades normalization from a termination statement to a **quantitative convergence law**. It would imply:
- metric convergence rates for evaluation,
- fixed-point principles for optimization passes,
- a quantitative semantics of strategy choice,
- a new “computational dynamics” viewpoint on proof normalization and rewriting.

However, the global uniform statement may be too optimistic. Your task is to settle the landscape decisively.

---

## Exact Theorem Targets

You must prove at least **3 substantial theorems**, with deep proof structure, and introduce at least **1 genuinely new definition**. The most promising architecture is to define a **strategy-sensitive contraction defect** and prove contractivity on a meaningful subclass.

### New Definitions to Introduce

Define a strategy-sensitive one-step evaluator and a quantitative defect measure.

Suggested concepts:

1. **Leftmost-outermost redex selector / deterministic evaluator**
   - A function or relation `loStep : Term → Option Term` or a deterministic predicate refining `BetaStep`.

2. **Head-active / strategy-visible distance**
   - A new quantity measuring whether the first discrepancy between two β-equivalent terms lies on the leftmost-outermost spine.

3. **Contraction defect**
   - A nonnegative quantity measuring how much strict contractivity can fail:
   \[
   \mathrm{defect}(t,u) := \mathrm{eqPathDist}(\mathrm{eval₁}(t),\mathrm{eval₁}(u)) - \alpha \,\mathrm{eqPathDist}(t,u)
   \]
   for a candidate `α ≤ 1`, or a combinatorial version avoiding subtraction over naturals.

4. **Strategy-stable pair**
   - A pair `(t,u)` such that both LO reductions target redexes lying on corresponding positions in a common β-equality witness.

These are not cosmetic: they are the conceptual machinery that can separate true contractive geometry from counterexamples.

---

## Precise Formalization Targets

You should align with the catalog files:

- `Catalog/Pythagorean/NormalizationBisimDistance.lean`
- `Catalog/Pythagorean/BoundedBetaDefs.lean`

and explicitly reuse / extend the lineage around:
- `eqPathDist_app_left_le`
- `eqPathDist_app_right_le`
- `eqPathDist_lam_le`

### Primary theorem candidate A: one-step strict decrease on visible-redex pairs

A promising formal statement is:

```lean
theorem eqPathDist_loStep_strict_of_visible
  {τ : SimpleType} {t u t' u' : STerm τ}
  (ht : loStep t = some t')
  (hu : loStep u = some u')
  (hβ : BetaEq t u)
  (hpos : 0 < eqPathDist t u)
  (hvis : VisiblePair t u) :
  eqPathDist t' u' + 1 ≤ eqPathDist t u
```

This is stronger than multiplicative contractivity on `ℕ`: it gives an additive decrease. From this you can derive a multiplicative estimate on bounded strata.

### Derived theorem candidate B: stratified contraction on bounded-distance shells

```lean
theorem eqPathDist_loStep_contracts_on_ball
  {τ : SimpleType} {R : ℕ} (hR : 0 < R) :
  ∃ c : ℚ, 0 ≤ c ∧ c < 1 ∧
    ∀ ⦃t u t' u' : STerm τ⦄,
      loStep t = some t' →
      loStep u = some u' →
      BetaEq t u →
      eqPathDist t u ≤ R →
      0 < eqPathDist t u →
      VisiblePair t u →
      (t' = t → False) →
      (u' = u → False) →
      (eqPathDist t' u' : ℚ) ≤ c * (eqPathDist t u : ℚ)
```

A canonical choice is `c = (R-1)/R`. This turns additive decrease into Banach-style contraction **on each bounded metric shell**.

### Primary theorem candidate C: obstruction / impossibility theorem if global contraction fails

If the global conjecture is false, prove a theorem of this form:

```lean
theorem no_uniform_strict_contraction_loStep
  {τ : SimpleType} :
  ¬ ∃ c : ℚ, 0 ≤ c ∧ c < 1 ∧
      ∀ ⦃t u t' u' : STerm τ⦄,
        loStep t = some t' →
        loStep u = some u' →
        BetaEq t u →
        0 < eqPathDist t u →
        (eqPathDist t' u' : ℚ) ≤ c * (eqPathDist t u : ℚ)
```

This would be a major positive result, not a failure: it identifies a **mathematical obstruction** and forces the correct refinement of the theory.

### Primary theorem candidate D: eventual contraction toward normal form

Once one-step additive decrease is proved on a visible subclass, derive a finite-time convergence estimate:

```lean
theorem iterate_loStep_reaches_normal_with_rate
  {τ : SimpleType} :
  ∀ ⦃t n⦄, n ≤ normalizationBudget t →
    ∃ k ≤ n, eqPathDist ((loIter k) t) (nf t) ≤ eqPathDist t (nf t) - k
```

or a cleaner bounded version if subtraction on naturals is awkward. This gives a true dynamical statement: the normal form is an attractor with explicit rate.

### Cross-domain theorem candidate E: fixed-point/dynamical systems bridge

Formalize the Banach-style consequence on finite metric strata:

```lean
theorem unique_fixed_point_on_bounded_beta_class
  {τ : SimpleType} {R : ℕ} :
  ∀ (C : Set (STerm τ)),
    Finite C →
    (∀ t ∈ C, ∃ t', loStep t = some t' ∧ t' ∈ C) →
    (∀ t u ∈ C, BetaEq t u → eqPathDist t u ≤ R) →
    StrategyVisibleClass C →
    ∃! n : STerm τ, n ∈ C ∧ IsNormalForm n
```

Even a more modest finite-class uniqueness theorem would be exciting: it connects λ-calculus to discrete metric dynamics.

---

## Lean 4 Type Signature Guidance

You must adapt to actual catalog names, but aim for theorem statements with explicit quantifiers and no ambiguity. If the catalog uses a different term type, preserve the theorem shape.

Possible signatures, to be adjusted to actual names:

```lean
def VisiblePair {τ : SimpleType} (t u : STerm τ) : Prop := ...
def loStep {τ : SimpleType} : STerm τ → Option (STerm τ) := ...
def contractionDefect {τ : SimpleType} (t u : STerm τ) : Int := ...

theorem loStep_betaStep
  {τ : SimpleType} {t u : STerm τ} :
  loStep t = some u → BetaStep t u := ...

theorem eqPathDist_loStep_le
  {τ : SimpleType} {t u t' u' : STerm τ} :
  loStep t = some t' →
  loStep u = some u' →
  BetaEq t u →
  eqPathDist t' u' ≤ eqPathDist t u := ...

theorem eqPathDist_loStep_strict_of_visible
  {τ : SimpleType} {t u t' u' : STerm τ} :
  loStep t = some t' →
  loStep u = some u' →
  BetaEq t u →
  0 < eqPathDist t u →
  VisiblePair t u →
  eqPathDist t' u' + 1 ≤ eqPathDist t u := ...

theorem no_uniform_strict_contraction_loStep
  {τ : SimpleType} :
  ¬ ∃ c : ℚ, 0 ≤ c ∧ c < 1 ∧
      ∀ ⦃t u t' u' : STerm τ⦄,
        loStep t = some t' →
        loStep u = some u' →
        BetaEq t u →
        0 < eqPathDist t u →
        (eqPathDist t' u' : ℚ) ≤ c * (eqPathDist t u : ℚ) := ...
```

If `eqPathDist` is `ℕ`-valued, use additive strict decrease as the primary theorem and derive rational contractivity only on bounded regions.

---

## Why This Would Be a Breakthrough

If you can prove strict contraction even on a substantial subclass, you create a new theory with immediate consequences:

- **Quantitative normalization theory:** not just “normalization terminates,” but “evaluation converges at a measurable rate.”
- **Operational dynamical systems:** reduction strategies become discrete flows on metric spaces of proofs/programs.
- **Optimization semantics:** iterative compiler rewrites can be certified to move toward a semantic attractor.
- **Quantitative type theory:** types control not only termination but contraction geometry.
- **Metric proof theory:** β-equivalence classes become geometric objects with dissipative structure.

This is exactly the kind of theorem that opens a new field rather than extending a lemma family.

---

## Proof Architecture: 3 Viable Strategies

You must include at least 2–3 proof approaches in your notes and pursue the strongest one.

### Strategy A — Induction on β-equality witness / path geometry
Most promising if `eqPathDist` is defined via shortest β-paths or bounded reachability.

1. Unfold `eqPathDist` into a minimal path/witness in `BetaEqIn` or `ReachableWithin`.
2. Show that when `loStep` contracts a strategy-visible redex, at least one segment of the witness shortens strictly.
3. Reassemble using catalog nonexpansiveness lemmas:
   - application-left,
   - application-right,
   - lambda congruence,
   while isolating the strict drop to the head spine.

**Why promising:** it directly exploits the existing catalog metric machinery and aligns with the supplied proof idea (“strictly decreases the step count for at least one path segment”).

### Strategy B — Context decomposition and spine factorization
Best if leftmost-outermost can be represented as reduction in a unique evaluation context.

1. Prove a decomposition theorem: every non-normal simply-typed term factors uniquely as `E[r]` where `r` is the LO redex.
2. Show `eqPathDist` is context-nonexpansive using the app/lam lineage.
3. Prove strict decrease on the redex core and lift through the context.

**Why promising:** if unique LO decomposition is available, strictness becomes local and conceptual. This is the cleanest route to a reusable “evaluation-context contractivity” framework.

### Strategy C — Counterexample-first, then repaired theorem
Use if global strict contraction fails.

1. Construct a family of β-equivalent typed pairs where LO reduction preserves distance.
2. Formalize the obstruction theorem `no_uniform_strict_contraction_loStep`.
3. Introduce `VisiblePair` / `HeadAligned` and prove strict contraction under that structural hypothesis.

**Why promising:** it guarantees a publishable outcome even if the grand conjecture is false. A no-go theorem plus repaired exact criterion is scientifically stronger than forcing a false global statement.

**Recommendation:** Start with Strategy C in parallel with A. It is the fastest path to truth. If no counterexample appears, continue with A. If one does, pivot to the repaired theorem and make the obstruction itself central.

---

## Required Deep Proof Tactics

At least 3 theorem proofs must materially use some combination of:
- induction on typing derivations, β-step derivations, or reachable-within witnesses,
- `rcases` on term forms and strategy decomposition,
- `by_contra` for impossibility/obstruction theorems,
- `field_simp` if rational contraction constants are introduced,
- multi-step `calc` chains combining catalog inequalities.

Do not trivialize the file with decidable computations. This project is about structure.

---

## Catalog Leverage Plan

Use the catalog theorems not as citations but as components:

- From `NormalizationBisimDistance.lean`, extract the exact monotonicity/nonexpansiveness behavior of `eqPathDist`.
- Extend:
  - `eqPathDist_app_left_le` to nested left-spine contexts,
  - `eqPathDist_app_right_le` to mixed context propagation,
  - `eqPathDist_lam_le` to abstraction-preserved visibility.
- From `BoundedBetaDefs.lean`, use `BetaStep`, `ReachableWithin`, and bounded path combinatorics to convert one-step strictness into shell-wise contraction constants.

If there is already a theorem giving nonexpansiveness under arbitrary one-step β-reduction, explicitly state how leftmost-outermost adds the missing strictness by selecting a canonical redex.

---

## Cross-Domain Connections You Must Exploit

Include at least one theorem or formal discussion connecting this work to another domain.

### 1. Dynamical systems / metric fixed-point theory
Interpret `loStep` as a discrete-time dynamical map on β-classes. Prove bounded-shell contraction or unique attractor results. This is the primary bridge.

### 2. Quantitative semantics / program optimization
Relate strict decrease of `eqPathDist` to convergence of repeated optimization passes. Even a theorem on finite reachable classes is significant.

### 3. Statistical physics / energy dissipation
Treat `eqPathDist` or a derived defect as a discrete Lyapunov function. A theorem stating that LO evaluation strictly decreases a “free energy” on visible pairs would be a memorable conceptual leap.

Suggested theorem shape:

```lean
theorem loStep_is_Lyapunov_decreasing
  {τ : SimpleType} {t u t' u' : STerm τ} :
  loStep t = some t' →
  loStep u = some u' →
  BetaEq t u →
  VisiblePair t u →
  lyapunov t' u' < lyapunov t u := ...
```

Even if `lyapunov := eqPathDist`, this framing matters.

---

## Falsifiable Conjectures to Include in FUTURE_DIRECTIONS.md

You must provide 3–5 testable hypotheses. At least one should be directly computationally falsifiable by finite enumeration.

Here are strong candidates:

1. **Uniform failure / structured success dichotomy**
   - Conjecture: global uniform `c < 1` fails, but for `VisiblePair` terms a universal additive drop of `1` holds.
   - Test: enumerate simply-typed pairs up to size 12, classify visible/non-visible, compare ratios and additive drops.

2. **Bounded-shell optimal constant**
   - Conjecture: on the shell `1 ≤ eqPathDist ≤ R`, the optimal contraction constant is exactly `(R-1)/R`.
   - Test: compute maximal observed ratio for each `R ≤ 8`.

3. **Type-order dependence**
   - Conjecture: lower type order yields stronger contraction; e.g. order-1 terms satisfy a smaller empirical contraction constant than higher-order terms.
   - Test: stratify enumerated terms by type order.

4. **Lyapunov uniqueness**
   - Conjecture: among deterministic normalizing strategies, leftmost-outermost uniquely minimizes expected one-step contraction defect.
   - Test: compare LO, leftmost-innermost, and random outermost on finite enumerations.

5. **Spectral-gap phenomenon**
   - Conjecture: the set of achievable ratios
     \[
     \frac{\mathrm{eqPathDist}(\mathrm{eval₁}(t),\mathrm{eval₁}(u))}{\mathrm{eqPathDist}(t,u)}
     \]
     has a gap below 1 on visible pairs.
   - Test: histogram ratios for visible pairs up to size 12.

These are scientifically meaningful because each can be disproved by a concrete finite search.

---

## Algorithmic Deliverable

You must produce a **verified computational method**, not just theorems.

### Required algorithm
Implement a certified analyzer that:
1. enumerates simply-typed terms up to a size bound,
2. filters β-equivalent pairs,
3. computes `eqPathDist`,
4. computes one-step LO reducts,
5. classifies pairs as `VisiblePair` / non-visible,
6. returns:
   - maximal observed ratio,
   - maximal additive defect,
   - candidate counterexamples to global strict contraction,
   - empirical shell-wise contraction constants.

If exact β-equivalence is expensive, use bounded witnesses from `ReachableWithin` and clearly state the search horizon.

The verified core should prove correctness of the evaluator / classifier, even if the exhaustive search orchestration lives partly in executable Lean or Python.

---

## demo.py Requirements

Provide an interactive `demo.py` that:
- generates typed λ-terms up to user-specified size,
- computes and plots the ratio
  \[
  \frac{\mathrm{eqPathDist}(\mathrm{eval₁}(t),\mathrm{eval₁}(u))}{\mathrm{eqPathDist}(t,u)}
  \]
  for β-equivalent pairs,
- highlights any pair with ratio `≥ 1`,
- separately visualizes visible vs non-visible pairs,
- estimates shell-wise best constants `c_R`,
- prints representative extremal pairs.

A compelling demo is a scatter plot of pre-distance vs post-distance, with the diagonal and shell contraction lines.

---

## Deliverables You Must Produce

You must produce **ALL** of the following:

1. **Lean file(s)** with at least 3 deep theorems and at least 1 novel definition.
2. **FUTURE_DIRECTIONS.md**
   - 3–5 falsifiable scientific hypotheses,
   - each with a concrete test that could refute it.
3. **RESEARCH_PAPER.md**
   - standalone scientific paper,
   - readable without code,
   - includes theorem statements, conceptual motivation, proof ideas, empirical findings, and next questions.
4. **ARTICLE.md**
   - Scientific American style,
   - explain the mathematical ideas and significance to a broad audience,
   - do **not** focus on formal verification machinery.
5. **Verified algorithm / computational method**
   - evaluator/classifier/analyzer with proved correctness of its core components.
6. **demo.py**
   - interactive empirical exploration of the contraction phenomenon.

---

## What Success Looks Like

A top-tier outcome is one of the following:

### Outcome 1: Full positive theorem
You prove a genuine uniform strict contraction theorem. This would be stunning.

### Outcome 2: Obstruction + repaired theorem
You prove no global `c < 1` exists, but identify the exact structural condition under which strict contraction holds. This is likely the most mathematically robust outcome.

### Outcome 3: Additive strict decrease + shell-wise Banach theorem
You show one-step LO evaluation decreases `eqPathDist` by at least 1 on a rich class, then derive bounded-shell multiplicative contraction and unique-attractor consequences. This already founds “computational dynamics.”

Any of these would be a field-opening contribution.

---

## Application Keywords

lambda calculus, simply-typed lambda calculus, beta reduction, leftmost-outermost evaluation, contraction mapping, Banach fixed-point theorem, discrete dynamical systems, Lyapunov function, metric rewriting, quantitative semantics, normalization rates, program optimization, proof theory, typed operational semantics, bounded reachability, evaluation contexts, spectral gap, energy dissipation, computational dynamics

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
