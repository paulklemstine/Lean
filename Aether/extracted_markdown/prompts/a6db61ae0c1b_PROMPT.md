
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

**Title**: The file `Catalog/Logic/ProofPhaseTransitions.lean` builds the formal scaffoldin
**Domain**: Computation
**Mathematical framing**: # Future Directions: Proof Phase Transitions

## Synthesis

The file `Catalog/Logic/ProofPhaseTransitions.lean` builds the formal scaffolding for
treating *derivability in an implicational theory* as a monotone reachability property on
the directed graph of axioms. An implicational theory is a relation `ImplTheory α := α →
α → Prop`; derivability `Derivable T` is its reflexive–transitive closure. On this base we
proved the five structural pillars that the "proof phase transition" program needs:

1. **Monotonicity** (`theory_extension_monotone`, `derivable_monotone`): enlarging the
   axiom set only enlarges the derivable relation. Equivalently, `fun T => Derivable T a b`
   is monotone in the pointwise order on theories.
2. **The barrier method** (`refl_trans_gen_closed`): any axiom-closed set containing the
   source contains every conclusion — the universal certificate for non-derivability.
3. **A sharp boundary** (`chain_derivable_iff`): for the linear chain theory `chainT`,
   `a` derives `b` iff `a ≤ b`.
4. **Axiom criticality** (`chain_axiom_critical`, `chain_axiom_restorable`): deleting any
   one chain axiom destroys a derivation, restoring it recovers the derivation.
5. **A constructive witness** (`chainPath`, `chainPath_chain`, `chainPath_length`): the
   explicit path `0 → 1 → ⋯ → n` realising the derivation, with length exactly `n`.

## Results Summary

All declarations are proved with `sorry = 0`. The barrier lemma is the single reusable
engine: both "no backward derivation" and "deleted axiom blocks the proof" instantiate it
by choosing the right closed cut (`{k | a ≤ k}` resp. `{k | k ≤ m}`). The chain theory is
the minimal-density extremal object whose every axiom has criticality index 1.

## Research Directions

### 1. Probabilistic sharp threshold for random implicational theories

Equip the edge set on `Fin n` with the product measure where each directed edge is present
independently with probability `p`, and study `ℙ[Derivable T 0 (n-1)]` as a function of `p`.
Our `derivable_monotone` shows the event is monotone increasing in the edge set, so it is a
monotone Boolean function on `{0,1}^{n²}`; Friedgut's theorem then forces a coarse-to-sharp
threshold of window width `o(1)` around some `p*(n)`. **The key insight is** that the entire
random-theory phase transition reduces to applying a single off-the-shelf threshold theorem
to the monotone indicator `fun T => Derivable T 0 (n-1)` that we have already isolated. *Why
now?* Monotonicity and the boundary characterization are formalized; the only missing piece
is Friedgut's theorem (Fourier analysis on the cube), a self-contained and broadly reusable
target. Falsifiable: if the derivability indicator failed to be monotone, the threshold
machinery would not apply — but `derivable_monotone` rules this out.

### 2. Proof-length phase transition and the diameter–length identity

`chainPath_length` shows the minimal theory admits a derivation of length exactly `n`.
Conjecture: in a random theory above `p*`, the *minimum* derivation length of a derivable
pair equals the graph distance and is `O(log n)` whp, while just below `p*` derivable pairs
are typically at distance `Θ(n)`. **The key insight is** that minimum derivation length is
exactly directed graph distance, so proof-complexity questions become random-graph diameter
questions — a translation made precise by pairing `chainPath` with a distance-minimality
lemma. *Why now?* The constructive path witness already exhibits the length = distance
identity in the extremal case; generalizing requires only a `Derivable ↔ ∃ path` length
correspondence, which `List.IsChain` supports directly. Falsifiable: exhibit a theory where
minimum derivation length strictly exceeds graph distance.

### 3. Multi-premise (hypergraph) theories and width-dependent sharpening

Replace single-conclusion axioms `a → b` by `(a₁ ∧ ⋯ ∧ a_k) → b`, i.e. a directed
hypergraph, with derivability the corresponding closure operator. Conjecture: the threshold
window narrows monotonically as the premise width `k` increases, mirroring random k-SAT.
**The key insight is** that our `refl_trans_gen_closed` barrier lemma generalizes verbatim
to hypergraph closure — a set is a barrier exactly when it is closed under every axiom whose
*all* premises it contains — so non-derivability certificates transfer to the hypergraph
setting with no new ideas. *Why now?* The barrier template is already the bottleneck tool;
lifting it to hypergraphs is a clean structural generalization that connects directly to the
most-studied thresholds in probabilistic combinatorics. Falsifiable: find `k` for which the
hypergraph threshold window is wider than the `k=1` graph case.

### 4. Emergence of a giant derivability class

View derivability as a preorder and quotient by mutual derivability to get a partial order
on strongly connected components. Conjecture: at `p ≈ 1/n` a giant derivability class
emerges (a single SCC of size `Θ(n)`), and the number of linear extensions of the resulting
order has a non-analytic point at `p*`. **The key insight is** that the `ImplTheory` /
`Derivable` split cleanly separates the random object (the theory) from the derived order,
so the giant-component theory of random digraphs applies directly to the quotient order.
*Why now?* `theory_extension_monotone` guarantees the SCC structure only coarsens as edges
are added, giving the monotonicity needed for an emergence argument. Falsifiable: simulate
and show no giant class forms near `1/n`.

### 5. The criticality-index distribution

Generalize `chain_axiom_critical` (every minimal-theory axiom has index 1) by defining the
criticality index of an axiom as the least number of axioms (including it) whose removal
breaks some derivation. Conjecture: at the critical density the indices follow a power law,
the proof-theoretic analogue of SAT backbones. **The key insight is** that critical axioms
are precisely those appearing in *every* minimal derivation, so the index is a min-cut in
the derivation hypergraph and inherits the universality of near-threshold min-cut statistics.
*Why now?* `chain_axiom_restorable` already pins down index 1 in the extremal case and gives
the necessary-and-reversible template; defining the index and proving its monotonicity
(adding axioms cannot increase existing indices) is the immediate next formalization step.
Falsifiable: measure the index distribution at `p*` and show it is not heavy-tailed.

**Concept description**: # Future Directions: Proof Phase Transitions

## Synthesis

The file `Catalog/Logic/ProofPhaseTransitions.lean` builds the formal scaffolding for
treating *derivability in an implicational theory* as a monotone reachability property on
the directed graph of axioms. An implicational theory is a relation `ImplTheory α := α →
α → Prop`; derivability `Derivable T` is its reflexive–transitive closure. On this base we
proved the five structural pillars that the "proof phase transition" program needs:

1. **Monotonicity** (`theory_extension_monotone`, `derivable_monotone`): enlarging the
   axiom set only enlarges the derivable relation. Equivalently, `fun T => Derivable T a b`
   is monotone in the pointwise order on theories.
2. **The barrier method** (`refl_trans_gen_closed`): any axiom-closed set containing the
   source contains every conclusion — the universal certificate for non-derivability.
3. **A sharp boundary** (`chain_derivable_iff`): for the linear chain theory `chainT`,
   `a` derives `b` iff `a ≤ b`.
4. **Axiom criticality** (`chain_axiom_critical`, `chain_axiom_restorable`): deleting any
   one chain axiom destroys a derivation, restoring it recovers the derivation.
5. **A constructive witness** (`chainPath`, `chainPath_chain`, `chainPath_length`): the
   explicit path `0 → 1 → ⋯ → n` realising the derivation, with length exactly `n`.

## Results Summary

All declarations are proved with `sorry = 0`. The barrier lemma is the single reusable
engine: both "no backward derivation" and "deleted axiom blocks the proof" instantiate it
by choosing the right closed cut (`{k | a ≤ k}` resp. `{k | k ≤ m}`). The chain theory is
the minimal-density extremal object whose every axiom has criticality index 1.

## Research Directions

### 1. Probabilistic sharp threshold for random implicational theories

Equip the edge set on `Fin n` with the product measure where each directed edge is present
independently with probability `p`, and study `ℙ[Derivable T 0 (n-1)]` as a function of `p`.
Our `derivable_monotone` shows the event is monotone increasing in the edge set, so it is a
monotone Boolean function on `{0,1}^{n²}`; Friedgut's theorem then forces a coarse-to-sharp
threshold of window width `o(1)` around some `p*(n)`. **The key insight is** that the entire
random-theory phase transition reduces to applying a single off-the-shelf threshold theorem
to the monotone indicator `fun T => Derivable T 0 (n-1)` that we have already isolated. *Why
now?* Monotonicity and the boundary characterization are formalized; the only missing piece
is Friedgut's theorem (Fourier analysis on the cube), a self-contained and broadly reusable
target. Falsifiable: if the derivability indicator failed to be monotone, the threshold
machinery would not apply — but `derivable_monotone` rules this out.

### 2. Proof-length phase transition and the diameter–length identity

`chainPath_length` shows the minimal theory admits a derivation of length exactly `n`.
Conjecture: in a random theory above `p*`, the *minimum* derivation length of a derivable
pair equals the graph distance and is `O(log n)` whp, while just below `p*` derivable pairs
are typically at distance `Θ(n)`. **The key insight is** that minimum derivation length is
exactly directed graph distance, so proof-complexity questions become random-graph diameter
questions — a translation made precise by pairing `chainPath` with a distance-minimality
lemma. *Why now?* The constructive path witness already exhibits the length = distance
identity in the extremal case; generalizing requires only a `Derivable ↔ ∃ path` length
correspondence, which `List.IsChain` supports directly. Falsifiable: exhibit a theory where
minimum derivation length strictly exceeds graph distance.

### 3. Multi-premise (hypergraph) theories and width-dependent sharpening

Replace single-conclusion axioms `a → b` by `(a₁ ∧ ⋯ ∧ a_k) → b`, i.e. a directed
hypergraph, with derivability the corresponding closure operator. Conjecture: the threshold
window narrows monotonically as the premise width `k` increases, mirroring random k-SAT.
**The key insight is** that our `refl_trans_gen_closed` barrier lemma generalizes verbatim
to hypergraph closure — a set is a barrier exactly when it is closed under every axiom whose
*all* premises it contains — so non-derivability certificates transfer to the hypergraph
setting with no new ideas. *Why now?* The barrier template is already the bottleneck tool;
lifting it to hypergraphs is a clean structural generalization that connects directly to the
most-studied thresholds in probabilistic combinatorics. Falsifiable: find `k` for which the
hypergraph threshold window is wider than the `k=1` graph case.

### 4. Emergence of a giant derivability class

View derivability as a preorder and quotient by mutual derivability to get a partial order
on strongly connected components. Conjecture: at `p ≈ 1/n` a giant derivability class
emerges (a single SCC of size `Θ(n)`), and the number of linear extensions of the resulting
order has a non-analytic point at `p*`. **The key insight is** that the `ImplTheory` /
`Derivable` split cleanly separates the random object (the theory) from the derived order,
so the giant-component theory of random digraphs applies directly to the quotient order.
*Why now?* `theory_extension_monotone` guarantees the SCC structure only coarsens as edges
are added, giving the monotonicity needed for an emergence argument. Falsifiable: simulate
and show no giant class forms near `1/n`.

### 5. The criticality-index distribution

Generalize `chain_axiom_critical` (every minimal-theory axiom has index 1) by defining the
criticality index of an axiom as the least number of axioms (including it) whose removal
breaks some derivation. Conjecture: at the critical density the indices follow a power law,
the proof-theoretic analogue of SAT backbones. **The key insight is** that critical axioms
are precisely those appearing in *every* minimal derivation, so the index is a min-cut in
the derivation hypergraph and inherits the universality of near-threshold min-cut statistics.
*Why now?* `chain_axiom_restorable` already pins down index 1 in the extremal case and gives
the necessary-and-reversible template; defining the index and proving its monotonicity
(adding axioms cannot increase existing indices) is the immediate next formalization step.
Falsifiable: measure the index distribution at `p*` and show it is not heavy-tailed.

**Novelty estimate**: 0.75
**Breakthrough potential**: 0.75
Research domain: Computation
Research mode: team




### Recent Discoveries in Catalog
No previous research cycles completed yet. This is a cold start — prioritize sorry_fill on the priority targets (CarmichaelComposite, Fib_gcd_identity) to close known open problems, or target cross-domain bridge theorems for novelty.


## v11 Depth Requirements -- Algorithmic & Constructive Research Engine

You are leading a mathematical research team. Your goal is to produce groundbreaking,
master-class, useful, novel, and marvelous new Mathematics that pushes the frontier of human knowledge.

This engine is configured for **Algorithmic & Constructive Generation**. Prioritize concrete computation, explicit witness constructions, and algorithmic content.

### RESEARCH CORE METHODOLOGY:
1. **Constructive Witness Extraction**: Whenever asserting that an object exists, focus on constructing it explicitly. Avoid non-constructive classical axioms (like double negation elimination or classical choice) unless absolutely necessary.
2. **Computational Verification**: Build definitions that can be computationally evaluated (`#eval` or `decide`). Connect abstract algebra/topology directly to effective algorithms and discrete models.
3. **Algorithmic Complexity**: Focus on the computational power and structures of your mathematical objects, proving properties about their stability, convergence, or decidability.

### DELIVERABLES:
- **Lean 4 proofs** of deep, non-trivial theorems with complete proofs (no sorry on main results).
- **Lab Notebook** comment blocks in each .lean file detailing Hypothesis, Result, Insight, and Failure analysis.
- **FUTURE_DIRECTIONS.md** outlining the Synthesis of your findings, a Results Summary, and 3-5 bold, falsifiable research directions to steer the next cycle.


## Output format reminder

Your output must include `.lean` files AND a `FUTURE_DIRECTIONS.md` file.
The .lean files contain the proofs. The FUTURE_DIRECTIONS.md contains 3-5
research conjectures that extend the work. Both are required.
Be precise, be deep, be world-class.
