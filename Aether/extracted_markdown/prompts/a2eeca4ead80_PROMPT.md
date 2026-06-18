            # Phase A Research Mission v16b: This document collects bold, falsifiable conjectures arising from the deepening 

            ## Concept
            **Domain**: MachineLearning
            **Research mode**: team
            **Title**: This document collects bold, falsifiable conjectures arising from the deepening 
            **Description**: # FUTURE DIRECTIONS — Valuation-Depth → Tropical Functor

This document collects bold, falsifiable conjectures arising from the deepening cycle
recorded in:

* `Catalog/Bridges/ValuationDepthTropicalFunctor.lean` (foundations: the upper bound
  `depth (eval t) ≤ maxLeafDepth t + height t`),
* `Catalog/Speculative/AutoResearch/ValuationDepthFollowups.lean` (C1–C5: sharpness,
  least Lipschitz constant, balanced/caterpillar, Hensel),
* `Catalog/Speculative/AutoResearch/ValuationDepthDeepening.lean` (D1–D5: the universal
  height–leaf duality `⌈log₂ numLeaves⌉ ≤ height ≤ numLeaves − 1`, the optimality
  sandwich, the generalized cost constant, the two-sided witness bound, and the universal
  linear-overhead bound),
* `Catalog/Speculative/AutoResearch/ValuationDepthOptimal.lean` (D6, **now proved**: the
  median-split tree `mkBalanced` attains height `⌈log₂ m⌉` for *every* leaf count `m ≥ 1`,
  so the cycle-1 lower bound is tight for all `m`, not only powers of two).

The unifying slogan now proved in both directions is:

> **height is the only cost, and `⌈log₂ leaves⌉ ≤ height ≤ leaves − 1` pins it on both sides.**

---

## D6 — Optimal reassociation exists for *every* leaf count  —  **RESOLVED (cycle 2)**

**Theorem (was conjecture).** For every `m ≥ 1` and every leaf value `k` there is a
combination tree `t` with `t.numLeaves = m` and `t.height = Nat.clog 2 m`; the universal
lower bound `clog_numLeaves_le_height` is *attained* for all `m`, not only powers of two.
Proved in `ValuationDepthOptimal.lean` via the median-split tree `mkBalanced` (split `m`
into `⌈m/2⌉ = (m+1)/2` and `⌊m/2⌋ = m/2`), `numLeaves_mkBalanced`, `height_mkBalanced`
(using `Nat.clog 2 m = Nat.clog 2 ⌈m/2⌉ + 1`), `optimal_height_attained`, and
`unitCost_optimal_depth`.  This upgrades D2 from the dyadic witnesses to a complete
optimality statement.  **Next:** D7 below now becomes the natural open frontier.

## D7 — The reassociation optimum equals `maxLeafDepth + ⌈log₂ leaves⌉`

**Conjecture.** Fix a multiset `L` of `m` leaf values on the unit-cost witness carrier.
The minimum of `t.eval unitCostAdd` over all trees `t` whose leaf multiset is `L` equals
`maxLeafDepth L + ⌈log₂ m⌉` when all leaf values are equal, and in general is governed by a
*tropical Huffman/Kraft* formula `min_t eval = ` the smallest `D` with
`∑_{ℓ∈L} 2^{depth(ℓ) − D} ≤ 1`.

*Test.* Prove the Kraft-style inequality `∑_{leaves} 2^{−(eval − value)} ≤ 1` for the
unit-cost evaluation (a tropical analogue of Kraft's inequality), then show the Huffman
construction attains it. The lower bound side already follows from D1.

## D8 — Carrier morphisms make `depth` a genuine lax functor (2-categorical upgrade)

**Conjecture.** Depth carriers and *cost-non-increasing maps* (`f : X.K → Y.K` with
`Y.depth (f a) ≤ X.depth a` and `f (X.add a b) = Y.add (f a) (f b)`) form a category, and
`depthTropMap` extends to a lax functor into `(ℕ, max, +1)` such that the tree bound
`depth_eval_add_le` is *natural*: it is preserved and reflected along carrier morphisms.

*Test.* Bundle `CarrierHom`, prove identity/composition laws, and show
`Y.depth ((t.map f).eval Y.add) ≤ X.depth (t.eval X.add)` (a functorial refinement of
`depth_eval_le_numLeaves`). This turns the "bridge" into a verified 2-functor.

## D9 — Mixed-cost carriers and a weighted-height invariant

**Conjecture.** If each *node* of the tree may use its own cost `cᵢ ∈ {0,1}` (idempotent vs
unit), then `depth (eval t) ≤ maxLeafDepth t + (number of unit-cost nodes on the longest
root-to-leaf path)`. The `c·height` bound of D3 is the constant-cost specialization, and
`depth_eval_add_le_strict` (all `cᵢ = 0`) is the zero-cost specialization; this conjecture
*interpolates* between them with a single weighted-height invariant.

*Test.* Annotate `OpTree` nodes with a `Bool` cost flag, define `weightedHeight`, and prove
the interpolating bound by structural induction. Verify it recovers D3 and the strict
theorem at the two extremes.

## D10 — Quantitative Hensel/Newton tower from the cost constant

**Conjecture.** The cost constant `c` of D3 controls p-adic precision *multiplicatively*:
a balanced cost-`c` Newton tower of height `n` reaches precision exactly `p^{c·n}` (so
classical quadratic convergence is the `c = 1`, base-`p²` instance, and `c ≥ 2` models
higher-order Householder iterations). C5's `hensel_depth_eq_height_and_precision` is the
`c = 1` case; `cost_eval_le_balanced` already gives the depth `b + c·n`.

*Test.* State precision as `p ^ ((costWitness c).depth (eval (balanced 0 n) ...))` and prove
it equals `p ^ (c·n)` from `cost_eval_le_balanced`; then connect to a concrete order-`(1+c)`
iteration on `ℤ_p` to certify the convergence rate.

---

### Methodological note

Each conjecture above is stated so that its *lower-bound half* already follows from a proved
theorem (D1/D3/C5), leaving an explicit **construction** to supply the matching upper bound.
This makes them immediately actionable for the next cycle: build the witness
(`mkBalanced`, Huffman tree, `CarrierHom`, weighted/annotated `OpTree`, Newton tower) and
discharge the equality via the existing bound.

            **Mathematical framing**: # FUTURE DIRECTIONS — Valuation-Depth → Tropical Functor

This document collects bold, falsifiable conjectures arising from the deepening cycle
recorded in:

* `Catalog/Bridges/ValuationDepthTropicalFunctor.lean` (foundations: the upper bound
  `depth (eval t) ≤ maxLeafDepth t + height t`),
* `Catalog/Speculative/AutoResearch/ValuationDepthFollowups.lean` (C1–C5: sharpness,
  least Lipschitz constant, balanced/caterpillar, Hensel),
* `Catalog/Speculative/AutoResearch/ValuationDepthDeepening.lean` (D1–D5: the universal
  height–leaf duality `⌈log₂ numLeaves⌉ ≤ height ≤ numLeaves − 1`, the optimality
  sandwich, the generalized cost constant, the two-sided witness bound, and the universal
  linear-overhead bound),
* `Catalog/Speculative/AutoResearch/ValuationDepthOptimal.lean` (D6, **now proved**: the
  median-split tree `mkBalanced` attains height `⌈log₂ m⌉` for *every* leaf count `m ≥ 1`,
  so the cycle-1 lower bound is tight for all `m`, not only powers of two).

The unifying slogan now proved in both directions is:

> **height is the only cost, and `⌈log₂ leaves⌉ ≤ height ≤ leaves − 1` pins it on both sides.**

---

## D6 — Optimal reassociation exists for *every* leaf count  —  **RESOLVED (cycle 2)**

**Theorem (was conjecture).** For every `m ≥ 1` and every leaf value `k` there is a
combination tree `t` with `t.numLeaves = m` and `t.height = Nat.clog 2 m`; the universal
lower bound `clog_numLeaves_le_height` is *attained* for all `m`, not only powers of two.
Proved in `ValuationDepthOptimal.lean` via the median-split tree `mkBalanced` (split `m`
into `⌈m/2⌉ = (m+1)/2` and `⌊m/2⌋ = m/2`), `numLeaves_mkBalanced`, `height_mkBalanced`
(using `Nat.clog 2 m = Nat.clog 2 ⌈m/2⌉ + 1`), `optimal_height_attained`, and
`unitCost_optimal_depth`.  This upgrades D2 from the dyadic witnesses to a complete
optimality statement.  **Next:** D7 below now becomes the natural open frontier.

## D7 — The reassociation optimum equals `maxLeafDepth + ⌈log₂ leaves⌉`

**Conjecture.** Fix a multiset `L` of `m` leaf values on the unit-cost witness carrier.
The minimum of `t.eval unitCostAdd` over all trees `t` whose leaf multiset is `L` equals
`maxLeafDepth L + ⌈log₂ m⌉` when all leaf values are equal, and in general is governed by a
*tropical Huffman/Kraft* formula `min_t eval = ` the smallest `D` with
`∑_{ℓ∈L} 2^{depth(ℓ) − D} ≤ 1`.

*Test.* Prove the Kraft-style inequality `∑_{leaves} 2^{−(eval − value)} ≤ 1` for the
unit-cost evaluation (a tropical analogue of Kraft's inequality), then show the Huffman
construction attains it. The lower bound side already follows from D1.

## D8 — Carrier morphisms make `depth` a genuine lax functor (2-categorical upgrade)

**Conjecture.** Depth carriers and *cost-non-increasing maps* (`f : X.K → Y.K` with
`Y.depth (f a) ≤ X.depth a` and `f (X.add a b) = Y.add (f a) (f b)`) form a category, and
`depthTropMap` extends to a lax functor into `(ℕ, max, +1)` such that the tree bound
`depth_eval_add_le` is *natural*: it is preserved and reflected along carrier morphisms.

*Test.* Bundle `CarrierHom`, prove identity/composition laws, and show
`Y.depth ((t.map f).eval Y.add) ≤ X.depth (t.eval X.add)` (a functorial refinement of
`depth_eval_le_numLeaves`). This turns the "bridge" into a verified 2-functor.

## D9 — Mixed-cost carriers and a weighted-height invariant

**Conjecture.** If each *node* of the tree may use its own cost `cᵢ ∈ {0,1}` (idempotent vs
unit), then `depth (eval t) ≤ maxLeafDepth t + (number of unit-cost nodes on the longest
root-to-leaf path)`. The `c·height` bound of D3 is the constant-cost specialization, and
`depth_eval_add_le_strict` (all `cᵢ = 0`) is the zero-cost specialization; this conjecture
*interpolates* between them with a single weighted-height invariant.

*Test.* Annotate `OpTree` nodes with a `Bool` cost flag, define `weightedHeight`, and prove
the interpolating bound by structural induction. Verify it recovers D3 and the strict
theorem at the two extremes.

## D10 — Quantitative Hensel/Newton tower from the cost constant

**Conjecture.** The cost constant `c` of D3 controls p-adic precision *multiplicatively*:
a balanced cost-`c` Newton tower of height `n` reaches precision exactly `p^{c·n}` (so
classical quadratic convergence is the `c = 1`, base-`p²` instance, and `c ≥ 2` models
higher-order Householder iterations). C5's `hensel_depth_eq_height_and_precision` is the
`c = 1` case; `cost_eval_le_balanced` already gives the depth `b + c·n`.

*Test.* State precision as `p ^ ((costWitness c).depth (eval (balanced 0 n) ...))` and prove
it equals `p ^ (c·n)` from `cost_eval_le_balanced`; then connect to a concrete order-`(1+c)`
iteration on `ℤ_p` to certify the convergence rate.

---

### Methodological note

Each conjecture above is stated so that its *lower-bound half* already follows from a proved
theorem (D1/D3/C5), leaving an explicit **construction** to supply the matching upper bound.
This makes them immediately actionable for the next cycle: build the witness
(`mkBalanced`, Huffman tree, `CarrierHom`, weighted/annotated `OpTree`, Newton tower) and
discharge the equality via the existing bound.





### Recent Discoveries in Catalog
No previous research cycles completed yet. This is a cold start — prioritize sorry_fill on the priority targets (CarmichaelComposite, Fib_gcd_identity) to close known open problems, or target cross-domain bridge theorems for novelty.


            ## v16 Research Core Methodology — Scientific Team Loop

You are the Principal Investigator leading a research team with four
roles: **Hypothesizer**, **Experimenter**, **Analyst**, and **Critic**.
Run the following loop and record notes at each stage.

### Stage 1 — Hypothesize (team: Hypothesizer)
Brainstorm 5–7 falsifiable conjectures about the topic. At least two
must be surprising or counter-intuitive. Rank them by expected
scientific impact, not by ease of proof.

### Stage 2 — Experiment (team: Experimenter)
For each conjecture, attempt to prove it in Lean 4 or disprove it with
a concrete counterexample. Prioritize the most surprising conjectures
first. If a proof is beyond reach, prove the strongest lemma you can
and mark the remaining step with exactly one `sorry` that is clearly
documented.

### Stage 3 — Analyze (team: Analyst)
Summarize what survived, what failed, and **why** failures failed.
Distinguish "true but hard", "false", and "needs a different
definition". These insights are as valuable as the proofs.

### Stage 4 — Critique / Adversarial Review (team: Critic)
Before finalizing, challenge every theorem:
- Is any theorem trivial (True, definitional equality, `native_decide`)?
- Does every main theorem have 0 sorries?
- Do the results genuinely extend the attached catalog files?
- Are there hidden assumptions or corner cases that break the claim?
If you find a weakness, fix it or replace the theorem with a guarded
version and explain the boundary.

### Stage 5 — Synthesize (team: Principal Investigator)
Combine the verified results into clean, compiling Lean 4 files.
Write a `FUTURE_DIRECTIONS.md` that lists 3–5 **bold, testable**
conjectures derived from Stage 3 and Stage 4. Each conjecture must
include a "The key insight is..." sentence and a "Why now?"
justification.

### Perpetual Scientific Iteration (do not stop at first synthesis)
When the research team comes together with results, do not stop. Treat the synthesized findings as the next problem statement and immediately run the full scientific-method loop again: hypothesize, experiment, review, synthesize, critique. Repeat this cycle continuously within the available context window, refining, deepening, and cross-checking until forced to emit output. Use Aristotle to its fullest.

### Extra Bridge Mandate (v16b)
At least one main theorem must import definitions or results from two
different catalog domains and combine them non-trivially. The Lab
Notes block must explicitly name which files from each domain were
used and what new connection they create.


            ### Anti-Trivial Guardrails (non-negotiable)
The following are NOT acceptable as main results:
- Theorems of the form `theorem name {X : Type*} [Inhabited X] : True := by trivial`.
- Definition-only theorems or definitional equalities proved by `rfl`.
- Results whose entire proof is `simp`, `norm_num`, `decide`, or `native_decide`.
- Wrapper types that rename existing definitions.
- Re-proving existing catalog theorems with minor notation changes.

Every main theorem must use at least one insight-bearing tactic or
technique such as `induction`, `by_contra`, `field_simp`, `ring_nf`,
`omega`, `linarith`, `rcases`, or a custom helper lemma.


            ### Deliverables & Acceptance Criteria
1. **Lean 4 files** (2–4 files in the appropriate `Catalog/<domain>/` subtree).
   - Main theorems must be fully proved (0 sorries).
   - Each file must contain `-- !-- Lab Notes -- !--` blocks documenting
     the team loop: Hypothesis, Experiment, Analysis, Critique, Synthesis.
2. **FUTURE_DIRECTIONS.md** with 3–5 bold, falsifiable conjectures derived
   from the cycle's findings. Each must have a "The key insight is..."
   sentence and a "Why now?" justification.

### Strictly Forbidden in Phase A
- `ARTICLE.md`, `RESEARCH_PAPER.md`, `demo.py`, HTML widgets, `PACKAGE.json`.
- Prose for human readers other than Lab Notes and FUTURE_DIRECTIONS.md.


            ## Self-Critique Checklist (perform before final output)
            Review your candidate output and answer each item. If the answer is
            unsatisfactory, revise the output before returning it.

            - [ ] No theorem is trivial (True, Inhabited-only, native_decide-only, etc.).
            - [ ] Every main theorem has 0 sorries.
            - [ ] At least one theorem imports or uses results from the attached catalog.
            - [ ] Lab Notes blocks contain real hypotheses, results, insights, and failure analysis.
            - [ ] FUTURE_DIRECTIONS.md conjectures are derived from this cycle's findings.
            - [ ] Every future direction includes a "The key insight is..." sentence and a "Why now?" justification.

            ## Output Format Reminder
            Return `.lean` files and `FUTURE_DIRECTIONS.md` only. Focus all compute
            on the mathematics.
