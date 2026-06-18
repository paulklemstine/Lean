            # Phase A Research Mission v16: This document records the bold, falsifiable conjectures arising from the third d

            ## Concept
            **Domain**: Geometry
            **Research mode**: team
            **Title**: This document records the bold, falsifiable conjectures arising from the third d
            **Description**: # FUTURE DIRECTIONS — Valuation-Depth → Tropical Functor (Cycle 3)

This document records the bold, falsifiable conjectures arising from the third deepening
cycle, which **resolved** four of the previously-open frontier conjectures D7–D10:

* `Catalog/Speculative/AutoResearch/ValuationDepthKraft.lean` — **D7 (Kraft half)**:
  the *sharp tropical Kraft identity* `∑_{leaves} 2^{-depth} = 1` for every `OpTree`
  (`kraft_eq_one`), the leaf-depth bookkeeping (`leafDepths_length`, `leafDepth_le_height`),
  and its packing corollary `numLeaves · 2^{-height} ≤ 1` (`kraft_card_bound`).
* `Catalog/Speculative/AutoResearch/ValuationDepthWeighted.lean` — **D9**: mixed-cost
  carriers with a per-node `Bool` cost flag, the interpolating bound
  `depth (eval t) ≤ maxLeafDepth + weightedHeight` (`depth_eval_le_weightedHeight`), and the
  proof that it strictly refines both extremes (`mixed_recovers_unit`,
  `mixed_recovers_strict`).
* `Catalog/Bridges/ValuationDepthCarrierFunctor.lean` — **D8**: carrier morphisms
  (`CarrierHom`) form a category (`id_comp`, `comp_id`, `comp_assoc`), `OpTree.map` is
  functorial on trees (`map_eval`), depth is non-increasing along morphisms
  (`depth_map_eval_le`), and the foundation bound is natural (`bound_natural`).
* `Catalog/Bridges/ValuationDepthHenselBridge.lean` — **D10 (cross-domain bridge)**: the
  tree-depth of a cost-`c` balanced tower equals the step count of a Hensel/Newton
  certificate, with p-adic precision `p^{c·n}` (`cost_tower_precision`,
  `cost_tower_hensel_bridge`); `c = 1` is exactly the classical quadratic certificate
  (`cost_tower_quadratic_at_one`).  This combines the **Speculative/AutoResearch** cost-tree
  theory with the **Computation** domain's `HenselConvergenceData`.

The unifying slogan, now proved along four new axes:

> **height is the only cost** — it saturates Kraft, it refines node-by-node into the
> weighted height, it is natural along carrier morphisms, and it *is* p-adic precision.

---

## D11 — Weighted Huffman optimum for mixed-cost carriers

**Conjecture.** Fix a leaf multiset `L` and an assignment of node costs in `{0,1}`.  The
minimum of `MTree.eval` over all flag-annotated trees on `L` equals a *weighted Huffman
optimum*: the smallest `D` such that `∑_{ℓ∈L} 2^{value(ℓ) − D} ≤ 1`, where only unit-cost
(`true`) nodes contribute to the exponent.  When all nodes are unit-cost this is the ordinary
tropical Kraft/Huffman optimum of D7; when all nodes are idempotent the optimum collapses to
`maxLeafDepth L`.

*The key insight is* that `kraft_eq_one` and `depth_eval_le_weightedHeight` are the two
halves of a single saturation phenomenon: the Kraft identity is exactly the statement that a
*unit-cost* tree spends one bit of "mass" per level, while the weighted-height bound shows
idempotent nodes spend none — so a mixed tree's optimum is governed by a Kraft sum that only
counts the unit nodes.

*Why now?* Both ingredients are freshly proved and 0-sorry in this cycle
(`kraft_eq_one`, `kraft_card_bound`, `depth_eval_le_weightedHeight`), so the only missing
piece is the Huffman *construction* matching the lower bound — a concrete recursion already
modelled by `mkBalanced`/`mark`.

## D12 — Naturality of the optimality sandwich along carrier morphisms

**Conjecture.** The cycle-1/cycle-2 optimality sandwich `⌈log₂ leaves⌉ ≤ height ≤ leaves − 1`
is *preserved and reflected* by `CarrierHom`: for a carrier morphism `f`, the optimal
reassociation in the source maps to an optimal reassociation in the target, and the median
tree `mkBalanced` is a natural transformation between the "free combination" functors.

*The key insight is* that `map_eval` makes evaluation a natural transformation and
`height_map` shows height is a *morphism invariant* — so every height-based optimality
statement is automatically functorial, and the bridge is not just a bound but a structure-
preserving 2-functor.

*Why now?* `bound_natural`, `map_eval`, and `height_map` (all proved this cycle) supply
exactly the naturality squares; what remains is to bundle them into a `CategoryTheory.Functor`
and exhibit `mkBalanced` as a `NatTrans`, reusing `optimal_height_attained`.

## D13 — The mixed-cost weighted height is the unique monotone interpolant

**Conjecture.** Among all functions `Φ` assigning to a flag-annotated tree an overhead
`depth (eval t) ≤ maxLeafDepth + Φ(t)` valid for *every* mixed-cost carrier, the weighted
height `weightedHeight` is the pointwise *least*; moreover it is the unique such `Φ` that is
additive across nodes and agrees with `height` on all-unit trees.

*The key insight is* that the per-node refinement of D9 is forced the same way the unit
constant `1` was forced in C2/D3: the unit-cost witness carrier attains equality at every
unit node and the strict witness attains equality at every idempotent node, pinning the
interpolant from both sides simultaneously.

*Why now?* `mixed_recovers_unit` and `mixed_recovers_strict` already establish equality at
the two extremes; an extremal-witness argument (mirroring `cost_least_constant`) over a
single mixed node should close the minimality, with no new infrastructure required.

## D14 — Concrete order-`(1+c)` Householder tower on ℤ_p

**Conjecture.** The abstract cost-`c` precision bridge `cost_tower_hensel_bridge` is realized
by a *concrete* order-`(1+c)` Householder iteration on `ℤ_p`: there is an explicit map
`N_c : ℤ_p → ℤ_p` whose `n`-fold balanced composition certifies a root to p-adic precision
exactly `p^{c·n}`, with `c = 1` Newton's method and `c = 2` Halley's method.

*The key insight is* that `cost_tower_precision` already identifies the *exponent* `c·n` with
the tree-depth of a balanced tower, so attaching a genuine `ℤ_p` contraction (via Mathlib's
`PadicInt.nonarchimedean`, used in `Catalog/Computation/PadicValuationDepth.lean`) turns the
combinatorial precision count into a certified analytic convergence rate.

*Why now?* The cross-domain scaffold is in place — the **Computation** domain supplies
`HenselConvergenceData.precision_exponential` and the p-adic ultrametric, while the
**Speculative/AutoResearch** domain supplies `cost_eval_le_balanced`; only the explicit
`ℤ_p` iterate `N_c` and its quadratic/cubic contraction estimate remain to be built.

            **Mathematical framing**: # FUTURE DIRECTIONS — Valuation-Depth → Tropical Functor (Cycle 3)

This document records the bold, falsifiable conjectures arising from the third deepening
cycle, which **resolved** four of the previously-open frontier conjectures D7–D10:

* `Catalog/Speculative/AutoResearch/ValuationDepthKraft.lean` — **D7 (Kraft half)**:
  the *sharp tropical Kraft identity* `∑_{leaves} 2^{-depth} = 1` for every `OpTree`
  (`kraft_eq_one`), the leaf-depth bookkeeping (`leafDepths_length`, `leafDepth_le_height`),
  and its packing corollary `numLeaves · 2^{-height} ≤ 1` (`kraft_card_bound`).
* `Catalog/Speculative/AutoResearch/ValuationDepthWeighted.lean` — **D9**: mixed-cost
  carriers with a per-node `Bool` cost flag, the interpolating bound
  `depth (eval t) ≤ maxLeafDepth + weightedHeight` (`depth_eval_le_weightedHeight`), and the
  proof that it strictly refines both extremes (`mixed_recovers_unit`,
  `mixed_recovers_strict`).
* `Catalog/Bridges/ValuationDepthCarrierFunctor.lean` — **D8**: carrier morphisms
  (`CarrierHom`) form a category (`id_comp`, `comp_id`, `comp_assoc`), `OpTree.map` is
  functorial on trees (`map_eval`), depth is non-increasing along morphisms
  (`depth_map_eval_le`), and the foundation bound is natural (`bound_natural`).
* `Catalog/Bridges/ValuationDepthHenselBridge.lean` — **D10 (cross-domain bridge)**: the
  tree-depth of a cost-`c` balanced tower equals the step count of a Hensel/Newton
  certificate, with p-adic precision `p^{c·n}` (`cost_tower_precision`,
  `cost_tower_hensel_bridge`); `c = 1` is exactly the classical quadratic certificate
  (`cost_tower_quadratic_at_one`).  This combines the **Speculative/AutoResearch** cost-tree
  theory with the **Computation** domain's `HenselConvergenceData`.

The unifying slogan, now proved along four new axes:

> **height is the only cost** — it saturates Kraft, it refines node-by-node into the
> weighted height, it is natural along carrier morphisms, and it *is* p-adic precision.

---

## D11 — Weighted Huffman optimum for mixed-cost carriers

**Conjecture.** Fix a leaf multiset `L` and an assignment of node costs in `{0,1}`.  The
minimum of `MTree.eval` over all flag-annotated trees on `L` equals a *weighted Huffman
optimum*: the smallest `D` such that `∑_{ℓ∈L} 2^{value(ℓ) − D} ≤ 1`, where only unit-cost
(`true`) nodes contribute to the exponent.  When all nodes are unit-cost this is the ordinary
tropical Kraft/Huffman optimum of D7; when all nodes are idempotent the optimum collapses to
`maxLeafDepth L`.

*The key insight is* that `kraft_eq_one` and `depth_eval_le_weightedHeight` are the two
halves of a single saturation phenomenon: the Kraft identity is exactly the statement that a
*unit-cost* tree spends one bit of "mass" per level, while the weighted-height bound shows
idempotent nodes spend none — so a mixed tree's optimum is governed by a Kraft sum that only
counts the unit nodes.

*Why now?* Both ingredients are freshly proved and 0-sorry in this cycle
(`kraft_eq_one`, `kraft_card_bound`, `depth_eval_le_weightedHeight`), so the only missing
piece is the Huffman *construction* matching the lower bound — a concrete recursion already
modelled by `mkBalanced`/`mark`.

## D12 — Naturality of the optimality sandwich along carrier morphisms

**Conjecture.** The cycle-1/cycle-2 optimality sandwich `⌈log₂ leaves⌉ ≤ height ≤ leaves − 1`
is *preserved and reflected* by `CarrierHom`: for a carrier morphism `f`, the optimal
reassociation in the source maps to an optimal reassociation in the target, and the median
tree `mkBalanced` is a natural transformation between the "free combination" functors.

*The key insight is* that `map_eval` makes evaluation a natural transformation and
`height_map` shows height is a *morphism invariant* — so every height-based optimality
statement is automatically functorial, and the bridge is not just a bound but a structure-
preserving 2-functor.

*Why now?* `bound_natural`, `map_eval`, and `height_map` (all proved this cycle) supply
exactly the naturality squares; what remains is to bundle them into a `CategoryTheory.Functor`
and exhibit `mkBalanced` as a `NatTrans`, reusing `optimal_height_attained`.

## D13 — The mixed-cost weighted height is the unique monotone interpolant

**Conjecture.** Among all functions `Φ` assigning to a flag-annotated tree an overhead
`depth (eval t) ≤ maxLeafDepth + Φ(t)` valid for *every* mixed-cost carrier, the weighted
height `weightedHeight` is the pointwise *least*; moreover it is the unique such `Φ` that is
additive across nodes and agrees with `height` on all-unit trees.

*The key insight is* that the per-node refinement of D9 is forced the same way the unit
constant `1` was forced in C2/D3: the unit-cost witness carrier attains equality at every
unit node and the strict witness attains equality at every idempotent node, pinning the
interpolant from both sides simultaneously.

*Why now?* `mixed_recovers_unit` and `mixed_recovers_strict` already establish equality at
the two extremes; an extremal-witness argument (mirroring `cost_least_constant`) over a
single mixed node should close the minimality, with no new infrastructure required.

## D14 — Concrete order-`(1+c)` Householder tower on ℤ_p

**Conjecture.** The abstract cost-`c` precision bridge `cost_tower_hensel_bridge` is realized
by a *concrete* order-`(1+c)` Householder iteration on `ℤ_p`: there is an explicit map
`N_c : ℤ_p → ℤ_p` whose `n`-fold balanced composition certifies a root to p-adic precision
exactly `p^{c·n}`, with `c = 1` Newton's method and `c = 2` Halley's method.

*The key insight is* that `cost_tower_precision` already identifies the *exponent* `c·n` with
the tree-depth of a balanced tower, so attaching a genuine `ℤ_p` contraction (via Mathlib's
`PadicInt.nonarchimedean`, used in `Catalog/Computation/PadicValuationDepth.lean`) turns the
combinatorial precision count into a certified analytic convergence rate.

*Why now?* The cross-domain scaffold is in place — the **Computation** domain supplies
`HenselConvergenceData.precision_exponential` and the p-adic ultrametric, while the
**Speculative/AutoResearch** domain supplies `cost_eval_le_balanced`; only the explicit
`ℤ_p` iterate `N_c` and its quadratic/cubic contraction estimate remain to be built.





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
