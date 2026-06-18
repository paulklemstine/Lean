
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

**Title**: Order-theoretic core of the Cook–Reckhow program built i
**Domain**: Applications
**Mathematical framing**: # Future Directions: The Poset of p-Degrees — Lattice Shape and Parametric Separation

## Synthesis

This cycle extended the order-theoretic core of the Cook–Reckhow program built in
`Catalog/Logic/ProofComplexity/SimulationPreorder.lean` (the p-simulation `Preorder`, the
`PEquiv` `Setoid`, and the Fibonacci separation) and `SimulationDegrees.lean` (the generic
non-polynomial separation template and two distinct p-degrees). The two new files determine
the **lattice-theoretic shape** of the simulation preorder and pin down its **bottom layer**.

`SimulationLattice.lean` shows that the direct sum `sumSystem P Q` of two abstract proof
systems is the **greatest lower bound** of `{P, Q}` (`sumSystem_isGLB`), so the simulation
preorder has binary meets and is downward directed (`simulationPreorder_codirected`,
`IsDirected _ (· ≥ ·)`). The only new arithmetic is closure of the polynomial blow-up class
under pointwise `max` (`polyMono_max`), mirroring the closure-under-composition that powered
transitivity in cycle 1.

`SimulationCollapse.lean` introduces the size-relabeled identity systems `idSystem sz` over
`Thm = ℕ` and proves the **polynomial collapse**: every honest polynomial-size system (size
polynomially bounded and at least linear) sits in a single p-degree
(`pEquiv_idSystem`, `idSystem_pEquiv_linSystem`, `linSystem_pEquiv_quadSystem`), while the
Fibonacci system stays strictly above it (`not_pEquiv_fib_lin`). Together with cycle 2's
`exists_two_distinct_pdegrees`, this gives a concrete two-layer skeleton: one polynomial
degree strictly below one Fibonacci degree, with binary meets available throughout.

## Results Summary

- `polyMono_max` — the monotone polynomial blow-up class is closed under pointwise maximum.
- `sumSystem` / `sumSystem_simulates_left` / `sumSystem_simulates_right` — the direct sum is
  a common lower bound (it simulates both summands via the identity blow-up).
- `sumSystem_greatest` / `sumSystem_isGLB` — the direct sum is the *greatest* lower bound: a
  genuine binary meet of `{P, Q}`.
- `simulationPreorder_codirected` — the simulation preorder is downward directed.
- `exists_monotone_polyBound` — every polynomial bound lies under a monotone one `(n+2)^k`.
- `pEquiv_idSystem` / `idSystem_pEquiv_linSystem` / `linSystem_pEquiv_quadSystem` — all
  honest polynomial-size systems collapse to one p-degree.
- `not_pEquiv_fib_lin` — that polynomial degree is strictly below the Fibonacci degree.

## Bold, Falsifiable Research Directions

### 1. The p-degree poset is a join-semilattice as well as a meet-semilattice

We proved binary *meets* (common strengthenings). Conjecture: the p-degree poset, on the
*antisymmetrization* `Antisymmetrization (ProofSystem ℕ) (· ≤ ·)`, also admits binary
*joins* (common weakenings) and is therefore a genuine lattice. The natural candidate for a
join of `P` and `Q` is the "intersection" system whose proofs certify only theorems provable
in *both* `P` and `Q`, with size the minimum of the two. The key insight is that a join must
be a system that *both* `P` and `Q` simulate, so it can only certify the common theorems and
must never be cheaper than either summand on them — the `min`-of-sizes restricted to the
shared theorem set is forced. Why now? The meet half is already mechanized and the blow-up
class is closed under `min` by the same one-line argument as `max` (`polyMono_max`), so the
order-theoretic scaffolding (`IsLUB`, `Antisymmetrization`) is in place; only the
intersection-system construction and its completeness witness remain, making this the lowest
hanging deep result. Falsifiable: exhibit `P`, `Q` with no least common weakener.

### 2. The polynomial degree is the unique bottom element of the p-degree poset

We showed all polynomial-size identity systems collapse to one degree and that the Fibonacci
degree lies strictly above it. Conjecture: the polynomial degree is the global **minimum**
of the entire p-degree poset of systems over `ℕ` (with `proves = id`) — every such system
p-simulates the linear system. The key insight is that simulating the linear system only
requires producing, for each theorem `n`, *some* proof of `n` whose size is polynomially
bounded in `n`, and any honest system already has *a* proof of `n`; the obstruction is purely
whether that system's *own* minimal proof sizes are super-polynomial, which never blocks
*being simulated by* the trivially-cheap linear system. Why now? `idSystem` and the
`simulates_idSystem_of` bridge already reduce the statement to a clean growth inequality, so
the conjecture is one quantifier-shuffle away from the existing API. Falsifiable: a system
the linear system fails to simulate would refute it.

### 3. There is a strictly increasing ω-chain of p-degrees

We have exactly two layers (polynomial < Fibonacci). Conjecture: the p-degree poset contains
an infinite strictly ascending chain `d_0 < d_1 < d_2 < ...`, witnessed by the iterated-
exponential hierarchy `sz_k = exp^{(k)}` (tower functions), with `idSystem sz_k` strictly
below `idSystem sz_{k+1}` because each tower function is super-polynomial in the previous.
The key insight is that strict separation in the simulation preorder is *exactly* the failure
of one growth class to polynomially dominate another, so a sequence of growth rates each
super-polynomial in its predecessor yields a strict chain mechanically via the existing
`no_simulation_of_hard` template. Why now? The parametric separation template already takes
an arbitrary non-polynomial hardness function `s`; instantiating it along a recursively
defined tower needs only a "tower beats poly of previous tower" lemma, a self-contained
arithmetic fact. Falsifiable: a collapse `d_k = d_{k+1}` at some level.

### 4. The p-degree poset embeds an antichain of size continuum

Conjecture: there is an antichain (pairwise p-incomparable degrees) of size `2^ℵ₀` among
systems over `ℕ`, indexed by subsets `S ⊆ ℕ` via systems that are super-polynomially hard
exactly on the theorems `n ∈ S`. The key insight is that two such systems are incomparable
precisely when neither index set's "hard" positions are polynomially dominated by the other's,
and a Sierpiński/almost-disjoint family of subsets of ℕ realizes continuum-many mutually
non-dominating hardness profiles. Why now? Incomparability reduces to two applications of the
`no_simulation_of_hard` template in opposite directions, and Mathlib already has almost-
disjoint families and cardinality-of-continuum infrastructure, so the missing piece is only
the bookkeeping that ties a hardness profile to a subset. Falsifiable: a proof that any two
degrees are comparable (a linearity theorem) would refute it.

### 5. A formal Cook–Reckhow theorem: NP = coNP iff a p-optimal (top) degree exists

The grand challenge. Conjecture (abstract Cook–Reckhow): the simulation preorder over a
*fixed honest theorem set* has a **maximum** p-degree (a single weakest system that every
system simulates — equivalently a p-optimal proof system in the classical sense) if and only
if the underlying tautology set is "self-provable" in a precise complexity-theoretic sense
that abstracts `NP = coNP`. The key insight is that the existence of a p-optimal system is a
purely order-theoretic top-element statement in our preorder, and the classical Cook–Reckhow
equivalence "NP = coNP ⟺ a polynomially bounded proof system exists" becomes, in the
abstract setting, a statement about the *top* of the p-degree poset — exactly dual to the
*bottom* (polynomial degree) we already characterized. Why now? Having mechanized meets,
directedness, and the bottom layer, the conceptual vocabulary for "top element" and
"bounded degree" is already present; formalizing the conditional equivalence isolates the one
genuinely hard import (a complexity-theoretic hypothesis) behind an honest Lean
`variable`/hypothesis, turning a grand challenge into a precise, checkable conditional.
Falsifiable: construct a theorem set with a maximum degree but no self-provability, or
vice versa.

**Concept description**: # Future Directions: The Poset of p-Degrees — Lattice Shape and Parametric Separation

## Synthesis

This cycle extended the order-theoretic core of the Cook–Reckhow program built in
`Catalog/Logic/ProofComplexity/SimulationPreorder.lean` (the p-simulation `Preorder`, the
`PEquiv` `Setoid`, and the Fibonacci separation) and `SimulationDegrees.lean` (the generic
non-polynomial separation template and two distinct p-degrees). The two new files determine
the **lattice-theoretic shape** of the simulation preorder and pin down its **bottom layer**.

`SimulationLattice.lean` shows that the direct sum `sumSystem P Q` of two abstract proof
systems is the **greatest lower bound** of `{P, Q}` (`sumSystem_isGLB`), so the simulation
preorder has binary meets and is downward directed (`simulationPreorder_codirected`,
`IsDirected _ (· ≥ ·)`). The only new arithmetic is closure of the polynomial blow-up class
under pointwise `max` (`polyMono_max`), mirroring the closure-under-composition that powered
transitivity in cycle 1.

`SimulationCollapse.lean` introduces the size-relabeled identity systems `idSystem sz` over
`Thm = ℕ` and proves the **polynomial collapse**: every honest polynomial-size system (size
polynomially bounded and at least linear) sits in a single p-degree
(`pEquiv_idSystem`, `idSystem_pEquiv_linSystem`, `linSystem_pEquiv_quadSystem`), while the
Fibonacci system stays strictly above it (`not_pEquiv_fib_lin`). Together with cycle 2's
`exists_two_distinct_pdegrees`, this gives a concrete two-layer skeleton: one polynomial
degree strictly below one Fibonacci degree, with binary meets available throughout.

## Results Summary

- `polyMono_max` — the monotone polynomial blow-up class is closed under pointwise maximum.
- `sumSystem` / `sumSystem_simulates_left` / `sumSystem_simulates_right` — the direct sum is
  a common lower bound (it simulates both summands via the identity blow-up).
- `sumSystem_greatest` / `sumSystem_isGLB` — the direct sum is the *greatest* lower bound: a
  genuine binary meet of `{P, Q}`.
- `simulationPreorder_codirected` — the simulation preorder is downward directed.
- `exists_monotone_polyBound` — every polynomial bound lies under a monotone one `(n+2)^k`.
- `pEquiv_idSystem` / `idSystem_pEquiv_linSystem` / `linSystem_pEquiv_quadSystem` — all
  honest polynomial-size systems collapse to one p-degree.
- `not_pEquiv_fib_lin` — that polynomial degree is strictly below the Fibonacci degree.

## Bold, Falsifiable Research Directions

### 1. The p-degree poset is a join-semilattice as well as a meet-semilattice

We proved binary *meets* (common strengthenings). Conjecture: the p-degree poset, on the
*antisymmetrization* `Antisymmetrization (ProofSystem ℕ) (· ≤ ·)`, also admits binary
*joins* (common weakenings) and is therefore a genuine lattice. The natural candidate for a
join of `P` and `Q` is the "intersection" system whose proofs certify only theorems provable
in *both* `P` and `Q`, with size the minimum of the two. The key insight is that a join must
be a system that *both* `P` and `Q` simulate, so it can only certify the common theorems and
must never be cheaper than either summand on them — the `min`-of-sizes restricted to the
shared theorem set is forced. Why now? The meet half is already mechanized and the blow-up
class is closed under `min` by the same one-line argument as `max` (`polyMono_max`), so the
order-theoretic scaffolding (`IsLUB`, `Antisymmetrization`) is in place; only the
intersection-system construction and its completeness witness remain, making this the lowest
hanging deep result. Falsifiable: exhibit `P`, `Q` with no least common weakener.

### 2. The polynomial degree is the unique bottom element of the p-degree poset

We showed all polynomial-size identity systems collapse to one degree and that the Fibonacci
degree lies strictly above it. Conjecture: the polynomial degree is the global **minimum**
of the entire p-degree poset of systems over `ℕ` (with `proves = id`) — every such system
p-simulates the linear system. The key insight is that simulating the linear system only
requires producing, for each theorem `n`, *some* proof of `n` whose size is polynomially
bounded in `n`, and any honest system already has *a* proof of `n`; the obstruction is purely
whether that system's *own* minimal proof sizes are super-polynomial, which never blocks
*being simulated by* the trivially-cheap linear system. Why now? `idSystem` and the
`simulates_idSystem_of` bridge already reduce the statement to a clean growth inequality, so
the conjecture is one quantifier-shuffle away from the existing API. Falsifiable: a system
the linear system fails to simulate would refute it.

### 3. There is a strictly increasing ω-chain of p-degrees

We have exactly two layers (polynomial < Fibonacci). Conjecture: the p-degree poset contains
an infinite strictly ascending chain `d_0 < d_1 < d_2 < ...`, witnessed by the iterated-
exponential hierarchy `sz_k = exp^{(k)}` (tower functions), with `idSystem sz_k` strictly
below `idSystem sz_{k+1}` because each tower function is super-polynomial in the previous.
The key insight is that strict separation in the simulation preorder is *exactly* the failure
of one growth class to polynomially dominate another, so a sequence of growth rates each
super-polynomial in its predecessor yields a strict chain mechanically via the existing
`no_simulation_of_hard` template. Why now? The parametric separation template already takes
an arbitrary non-polynomial hardness function `s`; instantiating it along a recursively
defined tower needs only a "tower beats poly of previous tower" lemma, a self-contained
arithmetic fact. Falsifiable: a collapse `d_k = d_{k+1}` at some level.

### 4. The p-degree poset embeds an antichain of size continuum

Conjecture: there is an antichain (pairwise p-incomparable degrees) of size `2^ℵ₀` among
systems over `ℕ`, indexed by subsets `S ⊆ ℕ` via systems that are super-polynomially hard
exactly on the theorems `n ∈ S`. The key insight is that two such systems are incomparable
precisely when neither index set's "hard" positions are polynomially dominated by the other's,
and a Sierpiński/almost-disjoint family of subsets of ℕ realizes continuum-many mutually
non-dominating hardness profiles. Why now? Incomparability reduces to two applications of the
`no_simulation_of_hard` template in opposite directions, and Mathlib already has almost-
disjoint families and cardinality-of-continuum infrastructure, so the missing piece is only
the bookkeeping that ties a hardness profile to a subset. Falsifiable: a proof that any two
degrees are comparable (a linearity theorem) would refute it.

### 5. A formal Cook–Reckhow theorem: NP = coNP iff a p-optimal (top) degree exists

The grand challenge. Conjecture (abstract Cook–Reckhow): the simulation preorder over a
*fixed honest theorem set* has a **maximum** p-degree (a single weakest system that every
system simulates — equivalently a p-optimal proof system in the classical sense) if and only
if the underlying tautology set is "self-provable" in a precise complexity-theoretic sense
that abstracts `NP = coNP`. The key insight is that the existence of a p-optimal system is a
purely order-theoretic top-element statement in our preorder, and the classical Cook–Reckhow
equivalence "NP = coNP ⟺ a polynomially bounded proof system exists" becomes, in the
abstract setting, a statement about the *top* of the p-degree poset — exactly dual to the
*bottom* (polynomial degree) we already characterized. Why now? Having mechanized meets,
directedness, and the bottom layer, the conceptual vocabulary for "top element" and
"bounded degree" is already present; formalizing the conditional equivalence isolates the one
genuinely hard import (a complexity-theoretic hypothesis) behind an honest Lean
`variable`/hypothesis, turning a grand challenge into a precise, checkable conditional.
Falsifiable: construct a theorem set with a maximum degree but no self-provability, or
vice versa.

**Novelty estimate**: 0.75
**Breakthrough potential**: 0.75
Research domain: Applications
Research mode: team




### Recent Discoveries in Catalog
No previous research cycles completed yet. This is a cold start — prioritize sorry_fill on the priority targets (CarmichaelComposite, Fib_gcd_identity) to close known open problems, or target cross-domain bridge theorems for novelty.


## v9 Depth Requirements -- Adversarial Ground-Truth Research Engine

You are leading a mathematical research team. Your goal is to produce groundbreaking,
master-class, useful, novel, and marvelous new Mathematics that pushes the frontier of human knowledge.

This engine is configured for **Adversarial Ground-Truth**. Trust nothing, assume everything is false until proven, and actively seek weaknesses. Think like an Adversarial Critic to pressure-test claims.

### RESEARCH CORE METHODOLOGY:
1. **Challenge Assumptions**: For every conjecture or theorem under investigation, actively search for counterexamples, corner cases, and boundary conditions. Proving that a claim is FALSE or identifying exactly where it fails is as valuable as a proof.
2. **Stress-Test the Frontier**: When a proof succeeds, push it to its limits. What happens if you drop or if a hypothesis is weakened? Write explicit comments documenting these boundary conditions.
3. **Relentless Rigor**: Write robust, clean, compilable Lean 4 proofs. Avoid trivial tautologies or simple wrapper theorems. Let your mathematical curiosity drive deep structural insights.

### DELIVERABLES:
- **Lean 4 proofs** of deep, non-trivial theorems with complete proofs (no sorry on main results).
- **Lab Notebook** comment blocks in each .lean file detailing Hypothesis, Result, Insight, and Failure analysis.
- **FUTURE_DIRECTIONS.md** outlining the Synthesis of your findings, a Results Summary, and 3-5 bold, falsifiable research directions to steer the next cycle.


## Output format reminder

Your output must include `.lean` files AND a `FUTURE_DIRECTIONS.md` file.
The .lean files contain the proofs. The FUTURE_DIRECTIONS.md contains 3-5
research conjectures that extend the work. Both are required.
Be precise, be deep, be world-class.
