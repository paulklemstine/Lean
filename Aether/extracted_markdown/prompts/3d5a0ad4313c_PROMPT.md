            # Phase A Research Mission v16: Follow-up conjectures arising from `Catalog/Bridges/ValuationDepthTropicalFuncto

            ## Concept
            **Domain**: Algebra
            **Research mode**: team
            **Title**: Follow-up conjectures arising from `Catalog/Bridges/ValuationDepthTropicalFuncto
            **Description**: # Future Directions

Follow-up conjectures arising from `Catalog/Bridges/ValuationDepthTropicalFunctor.lean`
(the 1-Lipschitz functor `depthTropObj`/`depthTropFunctor` from valuation-depth measures
`DepthCarrier` into tropical valuation objects `TropObj`, with the unit-cost laws
`depth (x ⊕ y) ≤ max (depth x) (depth y) + 1`).

Each conjecture is stated so that it can be made a precise Lean theorem (or disproved by
an explicit `DepthCarrier` witness) in a follow-up cycle.

## C1. Sharp unbalanced-tree bound (height is the *only* cost)
For every `DepthCarrier X` and every `t : OpTree X.K`,
`depth (t.eval X.add) ≤ maxLeafDepth depth t + ⌈log₂ (numLeaves t)⌉` is **false in general**
for unbalanced trees, but the *optimal reassociation* of the same multiset of leaves
satisfies it. Conjecture: there is a rebalancing operator `rebalance : OpTree K → OpTree K`
preserving `eval X.add` up to depth and achieving `height (rebalance t) = ⌈log₂ (numLeaves t)⌉`,
giving `depth (t.eval X.add) ≤ maxLeafDepth depth t + ⌈log₂ (numLeaves t)⌉` whenever `X.add`
is associative and commutative on depth values. Testable: prove or find an associative
`DepthCarrier` where no reassociation beats the height bound.

## C2. The unit cost is the unique Lipschitz constant of the bridge
Conjecture: among all constants `c : ℕ`, the law `depth (x ⊕ y) ≤ max (depth x) (depth y) + c`
holds for *every* `ValuationDepthMeasure`-derived carrier iff `c ≥ 1`, and `c = 1` is
attained (`witnessCarrier`). Formalize "the Lipschitz constant of `depthTropFunctor` equals 1"
and prove `c = 0` is refuted exactly by `not_strict_ultrametric_witness`. This pins the
functor's constant intrinsically rather than by construction.

## C3. Idempotent completion / strictification
Conjecture: every `DepthCarrier X` admits a universal *strict* (idempotent, `≤ max`) quotient
`Strictify X` with a 1-Lipschitz comparison map `X → Strictify X` that is initial among
morphisms to strict carriers (`IsStrict`). Equivalently, the inclusion of strict carriers
into all depth carriers has a left adjoint. Testable: construct `Strictify` (e.g. collapse
the `+1` slack by saturating depth under `add`) and prove the universal property, or exhibit
an `X` with no strict reflection.

## C4. Composition depth = max, not sum (UltrametricCompositionLaw functoriality)
The source file's `UltrametricCompositionLaw` posits `vdepth (f ∘ g) ≤ max + 1`. Conjecture:
the combination-tree theorem `depth_eval_add_le` has a *compositional* analogue: for a
composition tree whose nodes are `∘` and whose leaves carry `UltrametricCompositionLaw`
depths, `depth (eval ∘ t) ≤ maxLeafDepth depth t + height t`, and balanced composition of
`2^n` maps of depth `d` has depth exactly `d + n`. This would extend the 1-Lipschitz functor
from `(add, mul)` to `(∘)`, unifying it with `UltrametricCompositionLaw.vdepth_iterate_succ`.

## C5. Hensel certificate is a balanced tree (quantitative bridge)
Conjecture: the `HenselIterationComplexity` certificate (`newton_steps = log₂ target + 1`)
is the image under `depthTropFunctor` of a balanced `OpTree` of height `log₂ target` built
from a single quadratic-doubling step. Precisely: there is a `DepthCarrier` of Hensel states
in which the depth of the `n`-step lift equals the height of `balanced step n`, so
`depth_balanced_overhead_tight` *recovers* `HenselConvergenceData.precision_exponential`
and `speedup_ratio`. Testable: build the Hensel `DepthCarrier` and prove the depth of the
`k`-fold doubling tree equals `k`, matching `precision_exponential`'s `2^k` bound.

            **Mathematical framing**: # Future Directions

Follow-up conjectures arising from `Catalog/Bridges/ValuationDepthTropicalFunctor.lean`
(the 1-Lipschitz functor `depthTropObj`/`depthTropFunctor` from valuation-depth measures
`DepthCarrier` into tropical valuation objects `TropObj`, with the unit-cost laws
`depth (x ⊕ y) ≤ max (depth x) (depth y) + 1`).

Each conjecture is stated so that it can be made a precise Lean theorem (or disproved by
an explicit `DepthCarrier` witness) in a follow-up cycle.

## C1. Sharp unbalanced-tree bound (height is the *only* cost)
For every `DepthCarrier X` and every `t : OpTree X.K`,
`depth (t.eval X.add) ≤ maxLeafDepth depth t + ⌈log₂ (numLeaves t)⌉` is **false in general**
for unbalanced trees, but the *optimal reassociation* of the same multiset of leaves
satisfies it. Conjecture: there is a rebalancing operator `rebalance : OpTree K → OpTree K`
preserving `eval X.add` up to depth and achieving `height (rebalance t) = ⌈log₂ (numLeaves t)⌉`,
giving `depth (t.eval X.add) ≤ maxLeafDepth depth t + ⌈log₂ (numLeaves t)⌉` whenever `X.add`
is associative and commutative on depth values. Testable: prove or find an associative
`DepthCarrier` where no reassociation beats the height bound.

## C2. The unit cost is the unique Lipschitz constant of the bridge
Conjecture: among all constants `c : ℕ`, the law `depth (x ⊕ y) ≤ max (depth x) (depth y) + c`
holds for *every* `ValuationDepthMeasure`-derived carrier iff `c ≥ 1`, and `c = 1` is
attained (`witnessCarrier`). Formalize "the Lipschitz constant of `depthTropFunctor` equals 1"
and prove `c = 0` is refuted exactly by `not_strict_ultrametric_witness`. This pins the
functor's constant intrinsically rather than by construction.

## C3. Idempotent completion / strictification
Conjecture: every `DepthCarrier X` admits a universal *strict* (idempotent, `≤ max`) quotient
`Strictify X` with a 1-Lipschitz comparison map `X → Strictify X` that is initial among
morphisms to strict carriers (`IsStrict`). Equivalently, the inclusion of strict carriers
into all depth carriers has a left adjoint. Testable: construct `Strictify` (e.g. collapse
the `+1` slack by saturating depth under `add`) and prove the universal property, or exhibit
an `X` with no strict reflection.

## C4. Composition depth = max, not sum (UltrametricCompositionLaw functoriality)
The source file's `UltrametricCompositionLaw` posits `vdepth (f ∘ g) ≤ max + 1`. Conjecture:
the combination-tree theorem `depth_eval_add_le` has a *compositional* analogue: for a
composition tree whose nodes are `∘` and whose leaves carry `UltrametricCompositionLaw`
depths, `depth (eval ∘ t) ≤ maxLeafDepth depth t + height t`, and balanced composition of
`2^n` maps of depth `d` has depth exactly `d + n`. This would extend the 1-Lipschitz functor
from `(add, mul)` to `(∘)`, unifying it with `UltrametricCompositionLaw.vdepth_iterate_succ`.

## C5. Hensel certificate is a balanced tree (quantitative bridge)
Conjecture: the `HenselIterationComplexity` certificate (`newton_steps = log₂ target + 1`)
is the image under `depthTropFunctor` of a balanced `OpTree` of height `log₂ target` built
from a single quadratic-doubling step. Precisely: there is a `DepthCarrier` of Hensel states
in which the depth of the `n`-step lift equals the height of `balanced step n`, so
`depth_balanced_overhead_tight` *recovers* `HenselConvergenceData.precision_exponential`
and `speedup_ratio`. Testable: build the Hensel `DepthCarrier` and prove the depth of the
`k`-fold doubling tree equals `k`, matching `precision_exponential`'s `2^k` bound.





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
