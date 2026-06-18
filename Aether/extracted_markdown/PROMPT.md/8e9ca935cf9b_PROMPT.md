
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

**Title**: This cycle laid the missing foundation for the "proof phase transition" program.
**Domain**: Novelty
**Mathematical framing**: # Future Directions: Proof Phase Transitions in Random Implicational Theories

## Synthesis

This cycle laid the missing foundation for the "proof phase transition" program. The
concept brief referenced an infrastructure (`ImplTheory`, `Derivable`,
`theory_extension_monotone`, `chain_derivable`, the barrier method) that did not yet
exist anywhere in the catalog — a genuine cold start. We therefore built it from
scratch in `Catalog/Logic/ImplicationalThreshold.lean`, modelling an implicational
theory as a binary relation `T : α → α → Prop` (the directed edge set) and derivability
as its reflexive–transitive closure `Relation.ReflTransGen T`. This thin layer turns
out to be exactly the right abstraction: it exposes derivability as a *monotone* set
function of the axioms and admits a clean *barrier* certificate for non-derivability.

The two structural pillars are now formal. `theory_extension_monotone` proves that
`Derivable` is monotone increasing in the axiom relation — the precise hypothesis of
Friedgut's sharp-threshold theorem, and the reason a threshold should exist at all. Its
dual, `barrier_not_derivable` (via the invariance lemma `derivable_mem_of_closed`),
proves that any forward-closed set separating source from target certifies
non-derivability; this is the lower-bound half that a sharp-threshold proof consumes at
low density. The cross-domain payoff is `chain_axiom_critical`: on the minimal-density
chain theory, deleting any single axiom destroys derivability of `0 → n`. Its proof
*combines* the two pillars — the deleted theory is a subtheory (monotonicity) and the
down-set `{x ≤ k}` is the unique barrier created by the deletion — giving the first
formal "criticality index 1" statement.

What was tricky rather than what failed: the inductions over `Relation.ReflTransGen`
needed the right monovariant (`a ≤ ·` for `derivable_succ_iff`) and a strengthened
target (`derivable 0 → m for all m ≤ n`) to feed `chain_le_derivable`; and `omega`
cannot see through `Set` membership, so barrier goals must be `simp only
[Set.mem_setOf_eq]`-normalised first. These are the load-bearing idioms the next team
should reuse. The structural insight is that the whole random-theory program factors
through *monotonicity ⊕ barriers*, and every direction below is an instance of pushing
one of those two pillars into a richer setting.

## Results Summary

- `theory_extension_monotone`: proved — derivability is a monotone increasing property
  of the axiom set, the structural hypothesis behind any sharp-threshold statement.
- `derivable_mem_of_closed`: proved — forward-closed sets are invariant along
  derivations (the engine behind every barrier argument).
- `barrier_not_derivable`: proved — a forward-closed separating set certifies
  non-derivability; the low-density lower-bound tool.
- `derivable_succ_iff`: proved — boundary characterization: the successor theory on `ℕ`
  derives `a → b` iff `a ≤ b` (the deterministic endpoint of the random model).
- `chain_derivable`: proved — the length-`n` chain theory derives `0 → n` with a
  derivation of length exactly `n` (the graph diameter), anchoring proof-length study.
- `chain_axiom_critical`: proved — every chain axiom has criticality index `1`; deleting
  any single edge breaks `0 → n`. The headline cross-concept theorem (monotonicity ⊕
  barrier).

## Research Directions

### Direction 1: Probabilistic sharp threshold for random implicational theories
**Hypothesis**: For the random theory on `Fin n` where each directed edge is present
independently with probability `p`, there is a critical `p*(n)` such that
`Pr[Derivable T 0 (n-1)]` jumps from `≤ ε` to `≥ 1-ε` over a window of width `o(1)`
around `p*`.
**Test**: Formalize the event `Derivable T 0 (n-1)` as a monotone Boolean function on
`{0,1}^{n²}` using `theory_extension_monotone` to discharge monotonicity, then feed it
to a (to-be-formalized) Friedgut/Bourgain coarse-threshold theorem; numerically, sample
the empirical curve for small `n` to estimate `p*(n) ≈ log n / n`.
**Why now**: Monotonicity is now a one-liner (`theory_extension_monotone`), so the only
remaining ingredient is the general threshold theorem itself.
**If true**: Connects formal proof theory to the random-graph threshold machinery and
makes "proof phase transition" a theorem rather than a metaphor.
**If false**: Would mean derivability has a *coarse* threshold, revealing a genuine
proof-theoretic obstruction (a "pivotal-axiom" cluster) absent in ordinary connectivity.

### Direction 2: Proof-length thresholds and the diameter bound
**Hypothesis**: Define `minDerivLen T a b` as the least `k` with a `k`-step derivation.
On the chain theory, `minDerivLen (chain n) 0 n = n`; for random theories above `p*`,
`minDerivLen 0 (n-1) = O(log n / log(np))` with high probability, versus `∞` below.
**Test**: First prove the deterministic core — `minDerivLen (chain n) 0 n = n` and the
general lower bound `minDerivLen T a b ≥ graph distance` — by refining
`chain_le_derivable` into a length-counting induction; then layer the random diameter
estimate.
**Why now**: `chain_derivable` already realizes the diameter-length derivation; the only
new infrastructure is a `ℕ`-valued length function compatible with `ReflTransGen`.
**If true**: Bridges to resolution proof complexity (implicational derivation = monotone
resolution), importing random-`k`-CNF lower bounds.
**If false**: Short proofs exist even below the derivability threshold, indicating
proof-length and existence thresholds genuinely decouple.

### Direction 3: Hypergraph (multi-premise) theories and threshold sharpening
**Hypothesis**: For `k`-premise implications `(a₁ ∧ … ∧ a_k) → b` (directed
hypergraphs), derivability is still monotone, and the critical window narrows as `k`
grows, mirroring random `k`-SAT.
**Test**: Generalize `Derivable` to a hypergraph closure (least fixed point of "all
premises derived ⇒ conclusion derivable"), re-prove `theory_extension_monotone` and
`barrier_not_derivable` (the barrier becomes "closed under any rule all of whose
premises lie in `S`"), then study the window width as a function of `k`.
**Why now**: The barrier lemma `derivable_mem_of_closed` is stated purely via
forward-closure, so it generalizes to hypergraph closure almost verbatim — the
template is already in place.
**If true**: Directly connects this framework to the most studied object in
probabilistic combinatorics (random SAT thresholds).
**If false**: A `k`-independent window would signal that single-conclusion intuition
fails for hypergraph reachability, a surprising structural fact.

### Direction 4: Giant derivability component and order-entropy non-analyticity
**Hypothesis**: The derivability preorder (atoms ordered by `Derivable`) collapses, at
`p = 1/n`, from many small antichains to a single giant strongly-connected derivability
class, and the log-number of linear extensions has a non-analytic point at `p*`.
**Test**: Define the SCC quotient of `Derivable` and prove the deterministic anchors
(chain ⇒ a total order of `n+1` classes), then transport the random-digraph giant-SCC
theorem at `p = 1/n` through the `Derivable`/SCC correspondence.
**Why now**: The clean `ImplTheory`/`Derivable` split isolates the random object (edges)
from the derived structure (the preorder), exactly the separation needed to invoke
random-digraph theory.
**If true**: Gives a thermodynamic ("giant component") reading of proof-theoretic
phase transitions with a measurable order parameter.
**If false**: The derivability order's transition is decoupled from the SCC transition,
isolating a purely proof-theoretic emergence phenomenon.

### Direction 5: The criticality-index distribution and backbone universality
**Hypothesis**: Generalize `chain_axiom_critical` to define `critIndex T a b e` = least
number of axioms (including `e`) whose removal kills `Derivable T a b`. Then (i) the
index is monotone — adding axioms can only lower existing indices — and (ii) at
criticality the index distribution follows a power law, the proof-theoretic analogue of
SAT backbones.
**Test**: First prove the monotonicity lemma (a corollary of `theory_extension_monotone`
plus `barrier_not_derivable`), confirming chain edges have index `1`; then compute the
empirical index distribution for random theories near `p*`.
**Why now**: `chain_axiom_critical` is exactly the `critIndex = 1` base case, and its
monotonicity-⊕-barrier proof scheme is the template for the general monotonicity lemma.
**If true**: Establishes a universal backbone/criticality law across theory ensembles.
**If false**: A non-power-law (e.g. bimodal) distribution would expose theory-specific
proof structure violating constraint-satisfaction universality.

**Concept description**: # Future Directions: Proof Phase Transitions in Random Implicational Theories

## Synthesis

This cycle laid the missing foundation for the "proof phase transition" program. The
concept brief referenced an infrastructure (`ImplTheory`, `Derivable`,
`theory_extension_monotone`, `chain_derivable`, the barrier method) that did not yet
exist anywhere in the catalog — a genuine cold start. We therefore built it from
scratch in `Catalog/Logic/ImplicationalThreshold.lean`, modelling an implicational
theory as a binary relation `T : α → α → Prop` (the directed edge set) and derivability
as its reflexive–transitive closure `Relation.ReflTransGen T`. This thin layer turns
out to be exactly the right abstraction: it exposes derivability as a *monotone* set
function of the axioms and admits a clean *barrier* certificate for non-derivability.

The two structural pillars are now formal. `theory_extension_monotone` proves that
`Derivable` is monotone increasing in the axiom relation — the precise hypothesis of
Friedgut's sharp-threshold theorem, and the reason a threshold should exist at all. Its
dual, `barrier_not_derivable` (via the invariance lemma `derivable_mem_of_closed`),
proves that any forward-closed set separating source from target certifies
non-derivability; this is the lower-bound half that a sharp-threshold proof consumes at
low density. The cross-domain payoff is `chain_axiom_critical`: on the minimal-density
chain theory, deleting any single axiom destroys derivability of `0 → n`. Its proof
*combines* the two pillars — the deleted theory is a subtheory (monotonicity) and the
down-set `{x ≤ k}` is the unique barrier created by the deletion — giving the first
formal "criticality index 1" statement.

What was tricky rather than what failed: the inductions over `Relation.ReflTransGen`
needed the right monovariant (`a ≤ ·` for `derivable_succ_iff`) and a strengthened
target (`derivable 0 → m for all m ≤ n`) to feed `chain_le_derivable`; and `omega`
cannot see through `Set` membership, so barrier goals must be `simp only
[Set.mem_setOf_eq]`-normalised first. These are the load-bearing idioms the next team
should reuse. The structural insight is that the whole random-theory program factors
through *monotonicity ⊕ barriers*, and every direction below is an instance of pushing
one of those two pillars into a richer setting.

## Results Summary

- `theory_extension_monotone`: proved — derivability is a monotone increasing property
  of the axiom set, the structural hypothesis behind any sharp-threshold statement.
- `derivable_mem_of_closed`: proved — forward-closed sets are invariant along
  derivations (the engine behind every barrier argument).
- `barrier_not_derivable`: proved — a forward-closed separating set certifies
  non-derivability; the low-density lower-bound tool.
- `derivable_succ_iff`: proved — boundary characterization: the successor theory on `ℕ`
  derives `a → b` iff `a ≤ b` (the deterministic endpoint of the random model).
- `chain_derivable`: proved — the length-`n` chain theory derives `0 → n` with a
  derivation of length exactly `n` (the graph diameter), anchoring proof-length study.
- `chain_axiom_critical`: proved — every chain axiom has criticality index `1`; deleting
  any single edge breaks `0 → n`. The headline cross-concept theorem (monotonicity ⊕
  barrier).

## Research Directions

### Direction 1: Probabilistic sharp threshold for random implicational theories
**Hypothesis**: For the random theory on `Fin n` where each directed edge is present
independently with probability `p`, there is a critical `p*(n)` such that
`Pr[Derivable T 0 (n-1)]` jumps from `≤ ε` to `≥ 1-ε` over a window of width `o(1)`
around `p*`.
**Test**: Formalize the event `Derivable T 0 (n-1)` as a monotone Boolean function on
`{0,1}^{n²}` using `theory_extension_monotone` to discharge monotonicity, then feed it
to a (to-be-formalized) Friedgut/Bourgain coarse-threshold theorem; numerically, sample
the empirical curve for small `n` to estimate `p*(n) ≈ log n / n`.
**Why now**: Monotonicity is now a one-liner (`theory_extension_monotone`), so the only
remaining ingredient is the general threshold theorem itself.
**If true**: Connects formal proof theory to the random-graph threshold machinery and
makes "proof phase transition" a theorem rather than a metaphor.
**If false**: Would mean derivability has a *coarse* threshold, revealing a genuine
proof-theoretic obstruction (a "pivotal-axiom" cluster) absent in ordinary connectivity.

### Direction 2: Proof-length thresholds and the diameter bound
**Hypothesis**: Define `minDerivLen T a b` as the least `k` with a `k`-step derivation.
On the chain theory, `minDerivLen (chain n) 0 n = n`; for random theories above `p*`,
`minDerivLen 0 (n-1) = O(log n / log(np))` with high probability, versus `∞` below.
**Test**: First prove the deterministic core — `minDerivLen (chain n) 0 n = n` and the
general lower bound `minDerivLen T a b ≥ graph distance` — by refining
`chain_le_derivable` into a length-counting induction; then layer the random diameter
estimate.
**Why now**: `chain_derivable` already realizes the diameter-length derivation; the only
new infrastructure is a `ℕ`-valued length function compatible with `ReflTransGen`.
**If true**: Bridges to resolution proof complexity (implicational derivation = monotone
resolution), importing random-`k`-CNF lower bounds.
**If false**: Short proofs exist even below the derivability threshold, indicating
proof-length and existence thresholds genuinely decouple.

### Direction 3: Hypergraph (multi-premise) theories and threshold sharpening
**Hypothesis**: For `k`-premise implications `(a₁ ∧ … ∧ a_k) → b` (directed
hypergraphs), derivability is still monotone, and the critical window narrows as `k`
grows, mirroring random `k`-SAT.
**Test**: Generalize `Derivable` to a hypergraph closure (least fixed point of "all
premises derived ⇒ conclusion derivable"), re-prove `theory_extension_monotone` and
`barrier_not_derivable` (the barrier becomes "closed under any rule all of whose
premises lie in `S`"), then study the window width as a function of `k`.
**Why now**: The barrier lemma `derivable_mem_of_closed` is stated purely via
forward-closure, so it generalizes to hypergraph closure almost verbatim — the
template is already in place.
**If true**: Directly connects this framework to the most studied object in
probabilistic combinatorics (random SAT thresholds).
**If false**: A `k`-independent window would signal that single-conclusion intuition
fails for hypergraph reachability, a surprising structural fact.

### Direction 4: Giant derivability component and order-entropy non-analyticity
**Hypothesis**: The derivability preorder (atoms ordered by `Derivable`) collapses, at
`p = 1/n`, from many small antichains to a single giant strongly-connected derivability
class, and the log-number of linear extensions has a non-analytic point at `p*`.
**Test**: Define the SCC quotient of `Derivable` and prove the deterministic anchors
(chain ⇒ a total order of `n+1` classes), then transport the random-digraph giant-SCC
theorem at `p = 1/n` through the `Derivable`/SCC correspondence.
**Why now**: The clean `ImplTheory`/`Derivable` split isolates the random object (edges)
from the derived structure (the preorder), exactly the separation needed to invoke
random-digraph theory.
**If true**: Gives a thermodynamic ("giant component") reading of proof-theoretic
phase transitions with a measurable order parameter.
**If false**: The derivability order's transition is decoupled from the SCC transition,
isolating a purely proof-theoretic emergence phenomenon.

### Direction 5: The criticality-index distribution and backbone universality
**Hypothesis**: Generalize `chain_axiom_critical` to define `critIndex T a b e` = least
number of axioms (including `e`) whose removal kills `Derivable T a b`. Then (i) the
index is monotone — adding axioms can only lower existing indices — and (ii) at
criticality the index distribution follows a power law, the proof-theoretic analogue of
SAT backbones.
**Test**: First prove the monotonicity lemma (a corollary of `theory_extension_monotone`
plus `barrier_not_derivable`), confirming chain edges have index `1`; then compute the
empirical index distribution for random theories near `p*`.
**Why now**: `chain_axiom_critical` is exactly the `critIndex = 1` base case, and its
monotonicity-⊕-barrier proof scheme is the template for the general monotonicity lemma.
**If true**: Establishes a universal backbone/criticality law across theory ensembles.
**If false**: A non-power-law (e.g. bimodal) distribution would expose theory-specific
proof structure violating constraint-satisfaction universality.

**Novelty estimate**: 0.75
**Breakthrough potential**: 0.75
Research domain: Novelty
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
