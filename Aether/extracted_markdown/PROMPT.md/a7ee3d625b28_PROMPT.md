
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

**Title**: The foundational file `Catalog/Computation/SelfModifyingHalt.lean` established t
**Domain**: Novelty
**Mathematical framing**: # Future Directions — Discrete Dynamics of Self-Modification

## Synthesis

The foundational file `Catalog/Computation/SelfModifyingHalt.lean` established that a
self-modifying machine is *behaviourally* a standard machine over the product space
`P × S` (the simulation theorem `selfmod_halts_iff_standard`), so its halting problem
is Turing-equivalent to the classical one. The new file
`Catalog/Computation/SelfModDynamics.lean` pushes past behavioural equivalence into the
**dynamics** of the orbit itself, treating a never-halting (`Total`) machine as a
self-map `dyn : P × S → P × S` and transporting the elementary theory of finite
dynamical systems through the bridge lemma `run_eq_iter` (run = iterate of `dyn`).

Three structural facts emerge, two of them in tension:

1. **Finiteness makes prediction trivial.** `orbit_mem_initial_segment` confines every
   iterate to the first `card (P × S)` steps, so `selfmod_reaches_bad_iff_bounded`
   turns any infinite-horizon orbit property into a bounded search. On bounded memory,
   self-modification adds *no* analytic difficulty — a sharp counterpoint to the
   undecidability of the unbounded case.
2. **Finiteness forces self-reproduction.** `selfmod_quine_cycle` shows a total finite
   machine re-enters a previously visited configuration within `card` steps: a
   finitary Kleene/quine fixed point, answering Future Direction #2 of the foundation.
3. **Reachability — not step complexity — is where control fails.**
   `alignment_obstruction` shows that under strong connectivity a single misaligned
   state poisons the whole space: there is no nonempty forward-invariant safe region,
   so no state-based monitor can keep the agent aligned (Future Direction #4).

These results pin the difficulty of "alignment" squarely on the *reachability
relation* of the dynamics, not on the complexity of the step map.

## Results Summary

| Theorem | Statement |
|---|---|
| `dyn_eventually_periodic` | Every point of a finite self-map reaches a periodic point within `card` steps, with period `≤ card`. |
| `orbit_mem_initial_segment` | Every iterate already occurs among the first `card+1` iterates. |
| `selfmod_quine_cycle` | A total finite self-modifying machine reproduces a past configuration within `card (P×S)` steps and runs forever. |
| `selfmod_reaches_bad_iff_bounded` | "Ever reaches a bad config" reduces to a length-`card` search. |
| `alignment_obstruction` / `selfmod_alignment_obstruction` | Strong connectivity + one bad state ⇒ no nonempty safe region; every start reaches a bad state. |

All theorems compile with `sorry = 0` and depend only on `propext`,
`Classical.choice`, `Quot.sound`.

## Falsifiable Research Directions

### 1. Tight cycle-length bounds for linear self-modification
The quine-cycle bound `card (P × S)` is generic and almost never tight. Conjecture:
for *affine* self-modification on `P × S = (ZMod n)^d` — step `c ↦ Ac + b` for fixed
`A, b` — the maximal cycle length equals the multiplicative order of `A` in
`GL_d(ZMod n)` (times the additive contribution of `b`), which is exponentially
smaller than `n^d` for generic `A`. **The key insight is** that affine dynamics
factor through group theory, so cycle length is an *order* computation, not a search.
**Why now?** `selfmod_quine_cycle` already isolates "cycle length" as the right
invariant and Mathlib's `ZMod`, `Matrix`, and `orderOf` APIs make the affine case
fully formalizable today. *Falsifier:* exhibit an affine `A` whose realized cycle
length strictly exceeds `orderOf A` times the `b`-period.

### 2. Minimal reachability hypothesis for the alignment obstruction
`alignment_obstruction` assumes full strong connectivity, which is stronger than
needed. Conjecture: the obstruction survives under the strictly weaker hypothesis
"every configuration reaches *some* configuration from which a bad state is
reachable" (a single recurrent bad attractor in the condensation graph). **The key
insight is** that only the *terminal strongly connected component* of the orbit graph
matters, so alignment is possible iff there exists a bad-free terminal component.
**Why now?** The proof currently routes through `forwardInvariant_eq_univ_of_stronglyConnected`;
replacing "= univ" with "contains the terminal SCC" is a localizable edit, and the
condensation of a finite relation is elementary to define. *Falsifier:* a finite
machine with a bad-free terminal SCC yet no nonempty forward-invariant safe region.

### 3. Decidability lifts to a quantitative complexity bound
`selfmod_reaches_bad_iff_bounded` proves an *iff* with a bounded search but stops short
of a `Decidable` instance and a cost. Conjecture: for a `Total` machine on `P × S` the
predicate "the run ever enters `R`" is decidable in `O(card · cost(step))` time and
`O(card · log card)` space — a Floyd cycle-detection bound — and this is optimal.
**The key insight is** that orbit confinement means you never need more than `card`
simulated steps, so the halting/safety analysis is *linear* in the memory size despite
self-modification. **Why now?** The mathematical iff is already formalized; promoting it
to `Decidable` and proving the step count is a direct application of
`orbit_mem_initial_segment`. *Falsifier:* a family of total machines forcing
`ω(card)` step simulations to decide an orbit property.

### 4. Oracle stratification by self-modification depth
Generalize `Total` to a *depth-`k`* machine that may rewrite its program at most `k`
times before becoming fixed. Conjecture: the halting problem for depth-`k` machines is
`Σ⁰₁`-complete for every `k ≥ 0` (no climb in the arithmetical hierarchy), but the
*orbit-eventual-periodicity radius* on finite memory grows like `card^{k+1}`,
separating the depth levels *quantitatively* even though they coincide
*degree-theoretically*. **The key insight is** that self-modification depth is a
*resource* parameter (refining `card`-bounds) rather than a *degree* parameter — it
cannot cross the bridge that `selfmod_halts_iff_standard` already collapses. **Why now?**
This directly fuses the catalog's `OracleBurden` jump hierarchy with the new dynamics
layer; the depth filtration is definable on top of the existing `SelfModMachine`.
*Falsifier:* a depth-`1` machine whose halting set is properly `Σ⁰₂`, or a depth-`k`
family whose periodicity radius stays `O(card)`.

### 5. Probabilistic quine cycles and absorbing alignment
Replace the deterministic `dyn` by a Markov kernel on the finite space `P × S`
(stochastic code rewriting, as in real learning/malware systems). Conjecture: the
deterministic quine cycle becomes a *recurrent class*, and the alignment obstruction
becomes "if the unique recurrent class contains a bad state, the agent visits it
infinitely often almost surely". **The key insight is** that `IsPeriodic` is the `1`-step
specialization of "positive-recurrent communicating class", so the whole Section-2 theory
is the deterministic shadow of finite Markov-chain ergodics. **Why now?** Mathlib's
growing probability/finite-state-Markov infrastructure makes the stochastic lift feasible,
and the deterministic theorems give exact targets to specialize back to. *Falsifier:* a
finite kernel whose unique recurrent class contains a bad state yet which avoids that
state with positive probability from some start.

**Concept description**: # Future Directions — Discrete Dynamics of Self-Modification

## Synthesis

The foundational file `Catalog/Computation/SelfModifyingHalt.lean` established that a
self-modifying machine is *behaviourally* a standard machine over the product space
`P × S` (the simulation theorem `selfmod_halts_iff_standard`), so its halting problem
is Turing-equivalent to the classical one. The new file
`Catalog/Computation/SelfModDynamics.lean` pushes past behavioural equivalence into the
**dynamics** of the orbit itself, treating a never-halting (`Total`) machine as a
self-map `dyn : P × S → P × S` and transporting the elementary theory of finite
dynamical systems through the bridge lemma `run_eq_iter` (run = iterate of `dyn`).

Three structural facts emerge, two of them in tension:

1. **Finiteness makes prediction trivial.** `orbit_mem_initial_segment` confines every
   iterate to the first `card (P × S)` steps, so `selfmod_reaches_bad_iff_bounded`
   turns any infinite-horizon orbit property into a bounded search. On bounded memory,
   self-modification adds *no* analytic difficulty — a sharp counterpoint to the
   undecidability of the unbounded case.
2. **Finiteness forces self-reproduction.** `selfmod_quine_cycle` shows a total finite
   machine re-enters a previously visited configuration within `card` steps: a
   finitary Kleene/quine fixed point, answering Future Direction #2 of the foundation.
3. **Reachability — not step complexity — is where control fails.**
   `alignment_obstruction` shows that under strong connectivity a single misaligned
   state poisons the whole space: there is no nonempty forward-invariant safe region,
   so no state-based monitor can keep the agent aligned (Future Direction #4).

These results pin the difficulty of "alignment" squarely on the *reachability
relation* of the dynamics, not on the complexity of the step map.

## Results Summary

| Theorem | Statement |
|---|---|
| `dyn_eventually_periodic` | Every point of a finite self-map reaches a periodic point within `card` steps, with period `≤ card`. |
| `orbit_mem_initial_segment` | Every iterate already occurs among the first `card+1` iterates. |
| `selfmod_quine_cycle` | A total finite self-modifying machine reproduces a past configuration within `card (P×S)` steps and runs forever. |
| `selfmod_reaches_bad_iff_bounded` | "Ever reaches a bad config" reduces to a length-`card` search. |
| `alignment_obstruction` / `selfmod_alignment_obstruction` | Strong connectivity + one bad state ⇒ no nonempty safe region; every start reaches a bad state. |

All theorems compile with `sorry = 0` and depend only on `propext`,
`Classical.choice`, `Quot.sound`.

## Falsifiable Research Directions

### 1. Tight cycle-length bounds for linear self-modification
The quine-cycle bound `card (P × S)` is generic and almost never tight. Conjecture:
for *affine* self-modification on `P × S = (ZMod n)^d` — step `c ↦ Ac + b` for fixed
`A, b` — the maximal cycle length equals the multiplicative order of `A` in
`GL_d(ZMod n)` (times the additive contribution of `b`), which is exponentially
smaller than `n^d` for generic `A`. **The key insight is** that affine dynamics
factor through group theory, so cycle length is an *order* computation, not a search.
**Why now?** `selfmod_quine_cycle` already isolates "cycle length" as the right
invariant and Mathlib's `ZMod`, `Matrix`, and `orderOf` APIs make the affine case
fully formalizable today. *Falsifier:* exhibit an affine `A` whose realized cycle
length strictly exceeds `orderOf A` times the `b`-period.

### 2. Minimal reachability hypothesis for the alignment obstruction
`alignment_obstruction` assumes full strong connectivity, which is stronger than
needed. Conjecture: the obstruction survives under the strictly weaker hypothesis
"every configuration reaches *some* configuration from which a bad state is
reachable" (a single recurrent bad attractor in the condensation graph). **The key
insight is** that only the *terminal strongly connected component* of the orbit graph
matters, so alignment is possible iff there exists a bad-free terminal component.
**Why now?** The proof currently routes through `forwardInvariant_eq_univ_of_stronglyConnected`;
replacing "= univ" with "contains the terminal SCC" is a localizable edit, and the
condensation of a finite relation is elementary to define. *Falsifier:* a finite
machine with a bad-free terminal SCC yet no nonempty forward-invariant safe region.

### 3. Decidability lifts to a quantitative complexity bound
`selfmod_reaches_bad_iff_bounded` proves an *iff* with a bounded search but stops short
of a `Decidable` instance and a cost. Conjecture: for a `Total` machine on `P × S` the
predicate "the run ever enters `R`" is decidable in `O(card · cost(step))` time and
`O(card · log card)` space — a Floyd cycle-detection bound — and this is optimal.
**The key insight is** that orbit confinement means you never need more than `card`
simulated steps, so the halting/safety analysis is *linear* in the memory size despite
self-modification. **Why now?** The mathematical iff is already formalized; promoting it
to `Decidable` and proving the step count is a direct application of
`orbit_mem_initial_segment`. *Falsifier:* a family of total machines forcing
`ω(card)` step simulations to decide an orbit property.

### 4. Oracle stratification by self-modification depth
Generalize `Total` to a *depth-`k`* machine that may rewrite its program at most `k`
times before becoming fixed. Conjecture: the halting problem for depth-`k` machines is
`Σ⁰₁`-complete for every `k ≥ 0` (no climb in the arithmetical hierarchy), but the
*orbit-eventual-periodicity radius* on finite memory grows like `card^{k+1}`,
separating the depth levels *quantitatively* even though they coincide
*degree-theoretically*. **The key insight is** that self-modification depth is a
*resource* parameter (refining `card`-bounds) rather than a *degree* parameter — it
cannot cross the bridge that `selfmod_halts_iff_standard` already collapses. **Why now?**
This directly fuses the catalog's `OracleBurden` jump hierarchy with the new dynamics
layer; the depth filtration is definable on top of the existing `SelfModMachine`.
*Falsifier:* a depth-`1` machine whose halting set is properly `Σ⁰₂`, or a depth-`k`
family whose periodicity radius stays `O(card)`.

### 5. Probabilistic quine cycles and absorbing alignment
Replace the deterministic `dyn` by a Markov kernel on the finite space `P × S`
(stochastic code rewriting, as in real learning/malware systems). Conjecture: the
deterministic quine cycle becomes a *recurrent class*, and the alignment obstruction
becomes "if the unique recurrent class contains a bad state, the agent visits it
infinitely often almost surely". **The key insight is** that `IsPeriodic` is the `1`-step
specialization of "positive-recurrent communicating class", so the whole Section-2 theory
is the deterministic shadow of finite Markov-chain ergodics. **Why now?** Mathlib's
growing probability/finite-state-Markov infrastructure makes the stochastic lift feasible,
and the deterministic theorems give exact targets to specialize back to. *Falsifier:* a
finite kernel whose unique recurrent class contains a bad state yet which avoids that
state with positive probability from some start.

**Novelty estimate**: 0.75
**Breakthrough potential**: 0.75
Research domain: Novelty
Research mode: team




### Recent Discoveries in Catalog
No previous research cycles completed yet. This is a cold start — prioritize sorry_fill on the priority targets (CarmichaelComposite, Fib_gcd_identity) to close known open problems, or target cross-domain bridge theorems for novelty.


## v10 Depth Requirements -- Conceptual Unifier Research Engine

You are leading a mathematical research team. Your goal is to produce groundbreaking,
master-class, useful, novel, and marvelous new Mathematics that pushes the frontier of human knowledge.

This engine is configured for **Conceptual Unification (Grothendieck style)**. Search for deep, hidden structures, universal patterns, and bridges across domains.

### RESEARCH CORE METHODOLOGY:
1. **Abstract Structural Patterns**: Frame your objects and mappings in terms of universal structures, symmetries, and invariant properties. Look for the underlying categorical, topological, or algebraic foundations that make the specific problem a special case of a deeper truth.
2. **Cross-Domain Bridges**: Connect apparently distinct mathematical worlds (e.g. applying algebraic structures to computational complexity, or geometry to logic).
3. **Generalization Over Specialization**: Prefer elegant, universal formulations that unify multiple separate facts into single, coherent conceptual frameworks.

### DELIVERABLES:
- **Lean 4 proofs** of deep, non-trivial theorems with complete proofs (no sorry on main results).
- **Lab Notebook** comment blocks in each .lean file detailing Hypothesis, Result, Insight, and Failure analysis.
- **FUTURE_DIRECTIONS.md** outlining the Synthesis of your findings, a Results Summary, and 3-5 bold, falsifiable research directions to steer the next cycle.


## Output format reminder

Your output must include `.lean` files AND a `FUTURE_DIRECTIONS.md` file.
The .lean files contain the proofs. The FUTURE_DIRECTIONS.md contains 3-5
research conjectures that extend the work. Both are required.
Be precise, be deep, be world-class.
