
            ## PHASE A: LEAN 4 ONLY — DOING THE MATH

            You are leading a research team: Hypothesizer, Experimenter, Analyst,
Critic, and Synthesist. Run the loop:
Hypothesize -> Experiment -> Analyze -> Critique -> Generalize -> Iterate.
Your ONLY job is to produce **new Lean 4 code** and **take good notes**
for the next team.

            ### DELIVERABLES (strict — only this):
            1. **lean files (count chosen by theorem declarations)**
            2. **2-4 theorems with correct proofs (sorry = 0 on main results)**
            3. **Brief proof sketches** as `-- !-- comment -- !--` blocks (1-2 sentences each)
            4. **A FUTURE_DIRECTIONS.md file** listing 3-5 testable, falsifiable
               conjectures as a freeform narrative (NOT a form). Each direction MUST
               include a "The key insight is..." sentence and a "Why now?" justification.
               This file drives the next research cycle — make it count.
5. **Lab Notebook** as `-- !-- Lab Notebook -- !--` comment blocks
   in each .lean file: Hypothesis, Result, Insight, Failure analysis.

            ### DO NOT OUTPUT (Phase B handles these — if your work passes quality bar):
            - NO `ARTICLE.md`
            - NO `RESEARCH_PAPER.md`
            - NO `demo.py` / `algorithms.py`
            - NO HTML widgets
            - NO `PACKAGE.json`
            - NO prose for human readers (except FUTURE_DIRECTIONS.md)

            ### WHY THIS NARROW:
            The Lean 4 file IS the deliverable. A self-contained Lean file with
            3-5 world-class theorems is worth more than 30K characters of prose
            about trivial results. Focus 100% of your compute on the math.
            If your work is genuinely world-class, the packaging step is dispatched
            automatically and cheaply.

            ### CATALOG SYNTHESIS (required — read the catalog context below):
            The Catalog Context and Recent Discoveries sections list existing theorems
            already proven in this project. You MUST analyze these and combine concepts
            from the catalog with the research direction above. Specifically:

            1. **Identify relevant catalog theorems** — Which existing results connect
               to your research direction? Cite them by name in your proof sketches.
            2. **Build on catalog foundations** — Your theorems should EXTEND or
               GENERALIZE catalog results, not reprove them from scratch. Use `import`
               and reference existing definitions and lemmas where possible.
            3. **Combine concepts across domains** — The most valuable theorems connect
               ideas from different catalog domains (e.g., applying algebraic structures
               to topological problems, or using combinatorial arguments in number theory).
               Look for cross-domain connections in the catalog context.
            4. **Avoid duplication** — Check the catalog context before proving. If a
               similar result already exists, extend it rather than reproving it.


## Concept

**Title**: This cycle formalized the **abstract simulation preorder** at the core of the
**Domain**: Applications
**Mathematical framing**: # Future Directions: Proof System Collapse Theory

## Synthesis

This cycle formalized the **abstract simulation preorder** at the core of the
Cook–Reckhow program in proof complexity, in the new file
`Catalog/Logic/ProofSystemCollapse.lean`. The referenced source file did not yet
exist in the catalog (cold start), so rather than filling stale `sorry`
placeholders we built the object from scratch: an abstract `ProofSystem` over a
fixed theorem type, a parametric `BoundClass` of admissible proof-size blowup
functions, and the p-simulation relation `le B P Q` ("`P` is at least as powerful
as `Q`"). The central discovery is that the *entire* preorder structure rests on
exactly two closure axioms of the bound class — `contains_id` (reflexivity) and
`comp_closed` together with `mono` (transitivity). No arithmetic, no polynomials,
no model of computation is needed for the order-theoretic skeleton; concrete
classes like "polynomials" or "all monotone functions" are merely instances.

The structural payoff is the **collapse theorem**: mutual simulation (`Equiv`) is
an equivalence relation, and the quotient `Degree B T` carries a genuine
`PartialOrder` (`Degree.partialOrder`). The word "collapse" is literal — it is the
quotient construction. Critically, the Critic disproved antisymmetry on the *raw*
systems (`le_not_antisymm`): two systems over `Unit` differing only by a size
relabelling (`const 0` vs `const 1`) simulate each other yet are unequal. This
failure is exactly what forces the quotient and identifies the *degree* — not the
system — as the correct invariant object. The bounded structure (`le_top_system`,
`bot_system_le`) shows the preorder has a greatest "trivial" system (proves
everything in one step) and a least empty system, so degrees form a bounded poset.

What did not fit in this cycle: the *existence of a maximal degree* (an optimal
proof system) is the famous open Krajíček–Pudlák question and is left as a
conjecture below. The abstraction makes precise what such an element would be — a
top of `Degree.partialOrder` — and isolates exactly which concrete ingredient
(an effective universal bound) is missing from the order-theoretic core.

## Results Summary

- `le_refl`: proved — simulation is reflexive; reflexivity *is* the `contains_id` axiom.
- `le_trans`: proved — simulation composes via composition of bound functions, using `comp_closed` and `mono`.
- `preorder`: proved (def) — packages `le` into a `Preorder` for any bound class.
- `equiv_equivalence`: proved — mutual simulation is an equivalence relation.
- `le_top_system`: proved — the trivial system is a greatest element (top degree candidate).
- `bot_system_le`: proved — the empty system is a least element (bottom degree).
- `le_respects`: proved — simulation is invariant under mutual simulation, so it descends to the quotient.
- `Degree.partialOrder`: proved (def) — degrees of proof systems form a genuine partial order (the "collapse").
- `le_not_antisymm`: disproved (antisymmetry) — distinct systems can mutually simulate; the quotient is essential.

## Research Directions

### Direction 1: Optimality is a top element of the degree poset
**Hypothesis**: For the polynomial bound class over a suitable theorem type with an
effective universal simulator, `Degree.partialOrder` has an `OrderTop`; equivalently
there exists a degree `d` with `Degree.le B e d` for every `e`.
**Test**: Attempt to construct such a top in Lean for a concrete computable
`BoundClass` and theorem encoding; conversely, prove no top exists for a
"non-effective" bound class, separating the order question from the effectiveness
question.
**Why now**: This cycle reduced optimality to a single order-theoretic statement
(`OrderTop (Degree B T)`) and already provides `le_top_system` as a candidate top
in the *unbounded* setting — so the obstruction is provably the effectiveness of
the bound, not the order structure. The key insight is that p-optimality is
literally "the degree poset has a greatest element," cleanly separable from
computability.
**If true**: Gives a Lean-checkable interface for optimal proof systems and a target
for conditional results (e.g. under `NE = coNE`).
**If false (for a class)**: Pinpoints which closure property of `BoundClass` an
optimal system would have to violate, sharpening the Krajíček–Pudlák question.

### Direction 2: The degree poset is a lattice
**Hypothesis**: Degrees admit joins: for any two systems `P`, `Q` there is a system
`P ⊔ Q` whose degree is the least upper bound under `Degree.le` (take disjoint union
of proofs). Meets, however, fail in general.
**Test**: Define the disjoint-union system, prove its degree is a join, and search
for a counterexample to the existence of meets (two degrees with no greatest lower
bound).
**Why now**: With `Degree.partialOrder` in hand, lattice structure is the immediate
next order-theoretic question, and the disjoint-union construction needs only the
existing `BoundClass` axioms. The key insight is that "running two proof systems in
parallel" is exactly a categorical coproduct, which should realize the join.
**If true**: Upgrades degrees to a join-semilattice, enabling reasoning about
"combinations" of proof systems.
**If false for meets**: Shows the degree structure is fundamentally asymmetric,
mirroring the asymmetry between completeness and soundness blowups.

### Direction 3: Bound-class refinement induces poset morphisms
**Hypothesis**: If `B₁.mem ⊆ B₂.mem` (B₂ allows more blowup), then `le B₁ P Q →
le B₂ P Q`, and this induces a monotone surjection `Degree B₁ T → Degree B₂ T` that
collapses degrees as the bound class grows.
**Test**: Prove the implication on `le`, construct the induced map on quotients,
and exhibit two systems distinct in `Degree (polynomials)` but identified in
`Degree (exponentials)`.
**Why now**: `BoundClass` was deliberately abstracted this cycle, so comparing two
classes is now a first-class question; `le_respects` already shows how `le`
descends to quotients. The key insight is that "how much you may pad a proof"
is a tunable parameter, and coarsening it functorially collapses the degree poset.
**If true**: Yields a filtration of degree posets indexed by bound classes — a new
structural invariant of proof complexity.
**If false**: Reveals that simulation strength is not monotone in the bound budget,
an unexpected and instructive anomaly.

### Direction 4: Effective (functional) simulation strengthens the preorder
**Hypothesis**: Replacing the existential translation in `le` by an explicit
function `tr : Q.Proof → P.Proof` (constructive p-simulation) yields a preorder
that is *strictly finer* than `le`: there exist systems with `le B P Q` but no
bounded constructive translation.
**Test**: Define `leFun B P Q` with a witnessing function, prove it implies `le`,
prove it is a preorder, and construct a separating example using a non-constructive
existence of short proofs.
**Why now**: The current `le` uses bare `∃`; the proofs of `le_refl`/`le_trans`
make explicit that the witnesses are functions, so promoting them to data is a
small, well-scoped change. The key insight is that the classical p-simulation
distinguishes "short proofs exist" from "short proofs are computable," and only the
latter is algorithmically meaningful.
**If true**: Formalizes the constructive/non-constructive gap in proof complexity
inside a single comparable framework.
**If false**: Shows existential and functional simulation coincide abstractly,
isolating where the distinction must come from computability assumptions.

### Direction 5: Hard tautologies as antichains in the degree poset
**Hypothesis**: A family of theorems that is "hard" for system `Q` but "easy" for
`P` witnesses `¬ le B Q P`, and mutually hard families produce antichains of
incomparable degrees of arbitrary finite width.
**Test**: Add a `complexity : T → ℕ` lower-bound interface, prove a lemma
`(∀ q, Q.Proves q t → hard) → ¬ le B Q P` from a size lower bound, and build a
2-element antichain, then generalize to width `n`.
**Why now**: `le_not_antisymm` already manipulates explicit size functions to
separate systems; the same technique, applied to *lower* bounds instead of
relabellings, should yield incomparability. The key insight is that proof-size
lower bounds are precisely non-simulation certificates, turning hardness results
into order-theoretic structure.
**If true**: Connects concrete lower-bound theorems (resolution, cutting planes) to
the abstract degree poset, giving them an order-theoretic meaning.
**If false**: Indicates the abstract bound class is too permissive to see known
separations, prompting a more refined (e.g. uniform) `BoundClass`.

**Concept description**: # Future Directions: Proof System Collapse Theory

## Synthesis

This cycle formalized the **abstract simulation preorder** at the core of the
Cook–Reckhow program in proof complexity, in the new file
`Catalog/Logic/ProofSystemCollapse.lean`. The referenced source file did not yet
exist in the catalog (cold start), so rather than filling stale `sorry`
placeholders we built the object from scratch: an abstract `ProofSystem` over a
fixed theorem type, a parametric `BoundClass` of admissible proof-size blowup
functions, and the p-simulation relation `le B P Q` ("`P` is at least as powerful
as `Q`"). The central discovery is that the *entire* preorder structure rests on
exactly two closure axioms of the bound class — `contains_id` (reflexivity) and
`comp_closed` together with `mono` (transitivity). No arithmetic, no polynomials,
no model of computation is needed for the order-theoretic skeleton; concrete
classes like "polynomials" or "all monotone functions" are merely instances.

The structural payoff is the **collapse theorem**: mutual simulation (`Equiv`) is
an equivalence relation, and the quotient `Degree B T` carries a genuine
`PartialOrder` (`Degree.partialOrder`). The word "collapse" is literal — it is the
quotient construction. Critically, the Critic disproved antisymmetry on the *raw*
systems (`le_not_antisymm`): two systems over `Unit` differing only by a size
relabelling (`const 0` vs `const 1`) simulate each other yet are unequal. This
failure is exactly what forces the quotient and identifies the *degree* — not the
system — as the correct invariant object. The bounded structure (`le_top_system`,
`bot_system_le`) shows the preorder has a greatest "trivial" system (proves
everything in one step) and a least empty system, so degrees form a bounded poset.

What did not fit in this cycle: the *existence of a maximal degree* (an optimal
proof system) is the famous open Krajíček–Pudlák question and is left as a
conjecture below. The abstraction makes precise what such an element would be — a
top of `Degree.partialOrder` — and isolates exactly which concrete ingredient
(an effective universal bound) is missing from the order-theoretic core.

## Results Summary

- `le_refl`: proved — simulation is reflexive; reflexivity *is* the `contains_id` axiom.
- `le_trans`: proved — simulation composes via composition of bound functions, using `comp_closed` and `mono`.
- `preorder`: proved (def) — packages `le` into a `Preorder` for any bound class.
- `equiv_equivalence`: proved — mutual simulation is an equivalence relation.
- `le_top_system`: proved — the trivial system is a greatest element (top degree candidate).
- `bot_system_le`: proved — the empty system is a least element (bottom degree).
- `le_respects`: proved — simulation is invariant under mutual simulation, so it descends to the quotient.
- `Degree.partialOrder`: proved (def) — degrees of proof systems form a genuine partial order (the "collapse").
- `le_not_antisymm`: disproved (antisymmetry) — distinct systems can mutually simulate; the quotient is essential.

## Research Directions

### Direction 1: Optimality is a top element of the degree poset
**Hypothesis**: For the polynomial bound class over a suitable theorem type with an
effective universal simulator, `Degree.partialOrder` has an `OrderTop`; equivalently
there exists a degree `d` with `Degree.le B e d` for every `e`.
**Test**: Attempt to construct such a top in Lean for a concrete computable
`BoundClass` and theorem encoding; conversely, prove no top exists for a
"non-effective" bound class, separating the order question from the effectiveness
question.
**Why now**: This cycle reduced optimality to a single order-theoretic statement
(`OrderTop (Degree B T)`) and already provides `le_top_system` as a candidate top
in the *unbounded* setting — so the obstruction is provably the effectiveness of
the bound, not the order structure. The key insight is that p-optimality is
literally "the degree poset has a greatest element," cleanly separable from
computability.
**If true**: Gives a Lean-checkable interface for optimal proof systems and a target
for conditional results (e.g. under `NE = coNE`).
**If false (for a class)**: Pinpoints which closure property of `BoundClass` an
optimal system would have to violate, sharpening the Krajíček–Pudlák question.

### Direction 2: The degree poset is a lattice
**Hypothesis**: Degrees admit joins: for any two systems `P`, `Q` there is a system
`P ⊔ Q` whose degree is the least upper bound under `Degree.le` (take disjoint union
of proofs). Meets, however, fail in general.
**Test**: Define the disjoint-union system, prove its degree is a join, and search
for a counterexample to the existence of meets (two degrees with no greatest lower
bound).
**Why now**: With `Degree.partialOrder` in hand, lattice structure is the immediate
next order-theoretic question, and the disjoint-union construction needs only the
existing `BoundClass` axioms. The key insight is that "running two proof systems in
parallel" is exactly a categorical coproduct, which should realize the join.
**If true**: Upgrades degrees to a join-semilattice, enabling reasoning about
"combinations" of proof systems.
**If false for meets**: Shows the degree structure is fundamentally asymmetric,
mirroring the asymmetry between completeness and soundness blowups.

### Direction 3: Bound-class refinement induces poset morphisms
**Hypothesis**: If `B₁.mem ⊆ B₂.mem` (B₂ allows more blowup), then `le B₁ P Q →
le B₂ P Q`, and this induces a monotone surjection `Degree B₁ T → Degree B₂ T` that
collapses degrees as the bound class grows.
**Test**: Prove the implication on `le`, construct the induced map on quotients,
and exhibit two systems distinct in `Degree (polynomials)` but identified in
`Degree (exponentials)`.
**Why now**: `BoundClass` was deliberately abstracted this cycle, so comparing two
classes is now a first-class question; `le_respects` already shows how `le`
descends to quotients. The key insight is that "how much you may pad a proof"
is a tunable parameter, and coarsening it functorially collapses the degree poset.
**If true**: Yields a filtration of degree posets indexed by bound classes — a new
structural invariant of proof complexity.
**If false**: Reveals that simulation strength is not monotone in the bound budget,
an unexpected and instructive anomaly.

### Direction 4: Effective (functional) simulation strengthens the preorder
**Hypothesis**: Replacing the existential translation in `le` by an explicit
function `tr : Q.Proof → P.Proof` (constructive p-simulation) yields a preorder
that is *strictly finer* than `le`: there exist systems with `le B P Q` but no
bounded constructive translation.
**Test**: Define `leFun B P Q` with a witnessing function, prove it implies `le`,
prove it is a preorder, and construct a separating example using a non-constructive
existence of short proofs.
**Why now**: The current `le` uses bare `∃`; the proofs of `le_refl`/`le_trans`
make explicit that the witnesses are functions, so promoting them to data is a
small, well-scoped change. The key insight is that the classical p-simulation
distinguishes "short proofs exist" from "short proofs are computable," and only the
latter is algorithmically meaningful.
**If true**: Formalizes the constructive/non-constructive gap in proof complexity
inside a single comparable framework.
**If false**: Shows existential and functional simulation coincide abstractly,
isolating where the distinction must come from computability assumptions.

### Direction 5: Hard tautologies as antichains in the degree poset
**Hypothesis**: A family of theorems that is "hard" for system `Q` but "easy" for
`P` witnesses `¬ le B Q P`, and mutually hard families produce antichains of
incomparable degrees of arbitrary finite width.
**Test**: Add a `complexity : T → ℕ` lower-bound interface, prove a lemma
`(∀ q, Q.Proves q t → hard) → ¬ le B Q P` from a size lower bound, and build a
2-element antichain, then generalize to width `n`.
**Why now**: `le_not_antisymm` already manipulates explicit size functions to
separate systems; the same technique, applied to *lower* bounds instead of
relabellings, should yield incomparability. The key insight is that proof-size
lower bounds are precisely non-simulation certificates, turning hardness results
into order-theoretic structure.
**If true**: Connects concrete lower-bound theorems (resolution, cutting planes) to
the abstract degree poset, giving them an order-theoretic meaning.
**If false**: Indicates the abstract bound class is too permissive to see known
separations, prompting a more refined (e.g. uniform) `BoundClass`.

**Novelty estimate**: 0.75
**Breakthrough potential**: 0.75
Research domain: Applications
Research mode: team




### Recent Discoveries in Catalog
No previous research cycles completed yet. This is a cold start — prioritize sorry_fill on the priority targets (CarmichaelComposite, Fib_gcd_identity) to close known open problems, or target cross-domain bridge theorems for novelty.


## v14 Depth Requirements -- Synthetic Catalog Integration Engine

You are leading a mathematical research team. Your goal is to produce groundbreaking,
master-class, useful, novel, and marvelous new Mathematics that pushes the frontier of human knowledge.

This engine is configured for **Synthetic Catalog Integration**. Focus on building a coherent body of work on top of our existing catalog.

### RESEARCH CORE METHODOLOGY:
1. **Lineage Synthesis**: Analyze the existing catalog context deeply. Do not reinvent definitions; import and build directly on top of the validated catalog results.
2. **Connect the Dots**: Search for "orphan" results or gaps in the catalog and construct bridges to connect them. Show how new theorems advance the overall mathematical architecture of the repository.
3. **Foundational Extension**: Take successful packages from the catalog and extend their results to broader algebraic settings, sharper bounds, or new domain applications.

### DELIVERABLES:
- **Lean 4 proofs** of deep, non-trivial theorems with complete proofs (no sorry on main results).
- **Lab Notebook** comment blocks in each .lean file detailing Hypothesis, Result, Insight, and Failure analysis.
- **FUTURE_DIRECTIONS.md** outlining the Synthesis of your findings, a Results Summary, and 3-5 bold, falsifiable research directions to steer the next cycle.


## Output format reminder

Your output must include `.lean` files AND a `FUTURE_DIRECTIONS.md` file.
The .lean files contain the proofs. The FUTURE_DIRECTIONS.md contains 3-5
research conjectures that extend the work. Both are required.
Be precise, be deep, be world-class.
