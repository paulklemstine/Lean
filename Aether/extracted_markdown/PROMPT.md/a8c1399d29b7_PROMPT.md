
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

**Title**: *deterministic skeleton* of derivability phase
**Domain**: Logic
**Mathematical framing**: # Future Directions: Proof Phase Transitions

This cycle established the *deterministic skeleton* of derivability phase
transitions in `Catalog/Computation/ProofPhaseTransitions.lean`: an implicational
theory is a relation `T`, its consequences are `Derivable T = ReflTransGen T`,
and on finite edge sets the reachability predicate `EDeriv E src tgt` is a genuine
**monotone Boolean function** (`ederiv_mono`, `ederiv_upward_closed`). We proved the
barrier method for non-derivability (`barrier_not_derivable`), that the length-`n`
chain derives `0 ⟶ n` with exactly `n` axioms (`chain_derivable`, `chain_card`), and
that the chain is a **minimal certificate** — every axiom is critical
(`chain_edge_critical`, `chain_minimal_certificate`) — with a boundary case
(`redundant_edge_not_critical`) showing minimality is essential. These results are the
exact monotonicity-and-minimal-certificate inputs that a probabilistic threshold
theorem consumes.

## 1. Friedgut's sharp threshold for random implicational theories

Formalize the random model `G(n,p)` on `Fin n` where each directed edge is kept
independently with probability `p`, and prove that `ℙ[EDeriv 0 (n-1)]` jumps from
`o(1)` to `1 - o(1)` inside a window of vanishing width around a critical `p*(n)`.
The monotonicity hypothesis is *already discharged* by `ederiv_upward_closed`; what
remains is Friedgut's theorem itself.

The key insight is that `EDeriv E src tgt`, as `E` ranges over the cube
`{0,1}^{n²}`, is precisely a monotone Boolean function, so Friedgut's hypercontractive
/ Fourier-analytic argument applies verbatim once that machinery exists in Lean.

Why now? `ederiv_mono` and `chain_minimal_certificate` give both the monotonicity and
an explicit minimal certificate (the threshold's lower-bound witness); the only gap is
Fourier analysis on the Boolean cube, a reusable, broadly applicable formalization
target.

## 2. Proof-length phase transitions and resolution complexity

Refine derivability to *short* derivability: a sharp threshold for the existence of
derivations of length `≤ L(n)`. `chain_reach` already exhibits a length-`n` derivation;
conjecture that below `p*` minimum proofs are super-polynomial (or absent) and above
`p*` they are polynomial with high probability.

The key insight is that this implicational system is monotone resolution, so resolution
lower bounds for random CNF transfer directly to derivation-length lower bounds here.

Why now? `chain_minimal_certificate` pins the tight proof structure of minimal-density
theories; extending it needs only a formal `graph-diameter ↦ derivation-length` bridge,
built on the existing `chain_reach` prefix lemma.

## 3. Multi-premise theories and hypergraph thresholds

Generalize axioms `a → b` to `(a₁ ∧ … ∧ a_k) → b`, i.e. directed hypergraphs, so that
`Derivable` becomes `k`-uniform hyper-reachability. Re-establish the barrier method and
minimal-certificate theorems in this richer setting and study the `k`-dependence of the
threshold.

The key insight is that for `k ≥ 2` the critical window should sharpen as `k` grows,
mirroring the random `k`-SAT threshold; the down-set barrier of `chain_edge_critical`
generalizes to *closed* hypergraph barriers (sets closed under firing a hyperedge only
when all premises are inside).

Why now? `closed_preserved` + `barrier_not_derivable` are stated for arbitrary
relations, so the closure-under-firing template lifts almost mechanically to the
hypergraph closure operator.

## 4. Giant derivability component and order entropy

View derivability as a preorder on atoms and study, for random theories at density `p`,
the structural transition of the induced partial order on strongly connected
components: many small antichains below criticality, a giant derivability class above.
Conjecture a non-analytic point of the linear-extension entropy at `p*`.

The key insight is that the derivability order is the condensation of a random digraph,
so the emergence of a giant strongly connected component at `p ≈ 1/n` drives the
order-theoretic transition.

Why now? The clean `ImplTheory`/`Derivable` split formalized this cycle is exactly the
abstraction that lets random-digraph theory act on the derived order without entangling
the random object with its consequence relation.

## 5. Axiom criticality index and the proof-theoretic backbone

Define the criticality index of an axiom as the least number of axioms (including it)
whose removal breaks some derivation; in minimal theories this is `1`
(`chain_edge_critical`). Prove the monotonicity law — adding axioms can only decrease
existing criticality indices — and conjecture a power-law index distribution at the
critical density.

The key insight is that critical axioms are the proof-theoretic analogue of SAT
*backbone* variables (those fixed across all proofs), and phase-transition universality
predicts the same heavy-tailed statistics.

Why now? `chain_minimal_certificate` already isolates index-`1` axioms, and the
monotonicity law follows from `ederiv_mono` plus a `Finset.sdiff` bookkeeping argument,
making this the most immediate extension of the current infrastructure.

**Concept description**: # Future Directions: Proof Phase Transitions

This cycle established the *deterministic skeleton* of derivability phase
transitions in `Catalog/Computation/ProofPhaseTransitions.lean`: an implicational
theory is a relation `T`, its consequences are `Derivable T = ReflTransGen T`,
and on finite edge sets the reachability predicate `EDeriv E src tgt` is a genuine
**monotone Boolean function** (`ederiv_mono`, `ederiv_upward_closed`). We proved the
barrier method for non-derivability (`barrier_not_derivable`), that the length-`n`
chain derives `0 ⟶ n` with exactly `n` axioms (`chain_derivable`, `chain_card`), and
that the chain is a **minimal certificate** — every axiom is critical
(`chain_edge_critical`, `chain_minimal_certificate`) — with a boundary case
(`redundant_edge_not_critical`) showing minimality is essential. These results are the
exact monotonicity-and-minimal-certificate inputs that a probabilistic threshold
theorem consumes.

## 1. Friedgut's sharp threshold for random implicational theories

Formalize the random model `G(n,p)` on `Fin n` where each directed edge is kept
independently with probability `p`, and prove that `ℙ[EDeriv 0 (n-1)]` jumps from
`o(1)` to `1 - o(1)` inside a window of vanishing width around a critical `p*(n)`.
The monotonicity hypothesis is *already discharged* by `ederiv_upward_closed`; what
remains is Friedgut's theorem itself.

The key insight is that `EDeriv E src tgt`, as `E` ranges over the cube
`{0,1}^{n²}`, is precisely a monotone Boolean function, so Friedgut's hypercontractive
/ Fourier-analytic argument applies verbatim once that machinery exists in Lean.

Why now? `ederiv_mono` and `chain_minimal_certificate` give both the monotonicity and
an explicit minimal certificate (the threshold's lower-bound witness); the only gap is
Fourier analysis on the Boolean cube, a reusable, broadly applicable formalization
target.

## 2. Proof-length phase transitions and resolution complexity

Refine derivability to *short* derivability: a sharp threshold for the existence of
derivations of length `≤ L(n)`. `chain_reach` already exhibits a length-`n` derivation;
conjecture that below `p*` minimum proofs are super-polynomial (or absent) and above
`p*` they are polynomial with high probability.

The key insight is that this implicational system is monotone resolution, so resolution
lower bounds for random CNF transfer directly to derivation-length lower bounds here.

Why now? `chain_minimal_certificate` pins the tight proof structure of minimal-density
theories; extending it needs only a formal `graph-diameter ↦ derivation-length` bridge,
built on the existing `chain_reach` prefix lemma.

## 3. Multi-premise theories and hypergraph thresholds

Generalize axioms `a → b` to `(a₁ ∧ … ∧ a_k) → b`, i.e. directed hypergraphs, so that
`Derivable` becomes `k`-uniform hyper-reachability. Re-establish the barrier method and
minimal-certificate theorems in this richer setting and study the `k`-dependence of the
threshold.

The key insight is that for `k ≥ 2` the critical window should sharpen as `k` grows,
mirroring the random `k`-SAT threshold; the down-set barrier of `chain_edge_critical`
generalizes to *closed* hypergraph barriers (sets closed under firing a hyperedge only
when all premises are inside).

Why now? `closed_preserved` + `barrier_not_derivable` are stated for arbitrary
relations, so the closure-under-firing template lifts almost mechanically to the
hypergraph closure operator.

## 4. Giant derivability component and order entropy

View derivability as a preorder on atoms and study, for random theories at density `p`,
the structural transition of the induced partial order on strongly connected
components: many small antichains below criticality, a giant derivability class above.
Conjecture a non-analytic point of the linear-extension entropy at `p*`.

The key insight is that the derivability order is the condensation of a random digraph,
so the emergence of a giant strongly connected component at `p ≈ 1/n` drives the
order-theoretic transition.

Why now? The clean `ImplTheory`/`Derivable` split formalized this cycle is exactly the
abstraction that lets random-digraph theory act on the derived order without entangling
the random object with its consequence relation.

## 5. Axiom criticality index and the proof-theoretic backbone

Define the criticality index of an axiom as the least number of axioms (including it)
whose removal breaks some derivation; in minimal theories this is `1`
(`chain_edge_critical`). Prove the monotonicity law — adding axioms can only decrease
existing criticality indices — and conjecture a power-law index distribution at the
critical density.

The key insight is that critical axioms are the proof-theoretic analogue of SAT
*backbone* variables (those fixed across all proofs), and phase-transition universality
predicts the same heavy-tailed statistics.

Why now? `chain_minimal_certificate` already isolates index-`1` axioms, and the
monotonicity law follows from `ederiv_mono` plus a `Finset.sdiff` bookkeeping argument,
making this the most immediate extension of the current infrastructure.

**Novelty estimate**: 0.75
**Breakthrough potential**: 0.75
Research domain: Logic
Research mode: team




### Recent Discoveries in Catalog
No previous research cycles completed yet. This is a cold start — prioritize sorry_fill on the priority targets (CarmichaelComposite, Fib_gcd_identity) to close known open problems, or target cross-domain bridge theorems for novelty.


## v8 Depth Requirements -- Research Team Protocol

You are leading a research team. Your team has different roles:
- The **Hypothesizer** generates bold, falsifiable conjectures
- The **Experimenter** proves or disproves them in Lean 4
- The **Analyst** examines what survived, what failed, and WHY
- The **Critic** searches for weaknesses, constructs counterexamples,
  and identifies where proofs might break down. A well-constructed
  counterexample is as valuable as a proof.
- The **Synthesist** upgrades the knowledge base and writes the
  FUTURE_DIRECTIONS.md that seeds the next cycle

You run this loop: **Hypothesize -> Experiment -> Analyze -> Critique -> Generalize -> Iterate**.
Each cycle is not a one-shot task. It is one iteration of an infinite
research process. Your notes (FUTURE_DIRECTIONS.md, Lab Notebooks,
proof sketches) determine whether the next team builds on your work
or starts over.

**Take good notes.** A cycle without useful notes is a wasted cycle.

### STEP 1: THEOREM DECLARATIONS (required -- before any code)

List every theorem you intend to prove or investigate. For each, state:
- **Name**: The Lean declaration name
- **Statement**: One-sentence informal statement
- **Status**: `hypothesis` | `conjecture` | `proved` | `proved_with_lemma_sorry` | `disproved`
- **Why it matters**: One sentence on what this result would mean if true,
  and what it would teach us if false

Example:
1. `cantorPairing_surjective`: Cantor pairing is surjective -- proved -- constructive inverse -- confirms decidability of Nat x Nat
2. `cantorPairing_injective`: Cantor pairing is injective -- proved -- diagonal argument -- confirms invertibility
3. `cantorPairing_bijection`: Cantor pairing is a bijection -- proved_with_lemma_sorry -- follows from 1+2 -- completing the characterization

Use `hypothesis` for statements you are not yet sure you can prove but
want to investigate. Use `conjecture` for statements you believe are true
but cannot prove in this cycle. Use `disproved` for statements where you
found a counterexample. Use `proved` for statements with complete Lean
proofs. Use `proved_with_lemma_sorry` when the main proof is complete but
one or more supporting lemmas use `sorry`.

### STEP 2: EXPERIMENT (prove or disprove in Lean 4)

Every theorem declared as `proved` MUST have a complete, compiling Lean proof.
No `sorry` on the main result. If you cannot complete a proof, change its
status to `conjecture` or `proved_with_lemma_sorry` and explain why.

For `proved_with_lemma_sorry`:
- The theorem statement must be complete (no sorry in the statement)
- `sorry` is allowed ONLY in supporting lemmas, never the main proof
- A comment must explain what the sorry replaces and why it is deferred

**Disproofs count.** If a hypothesis is false, prove its negation or
construct an explicit counterexample. A well-constructed counterexample
is as valuable as a proof. Change the status to `disproved` and state
the counterexample clearly.

### STEP 3: CRITIQUE (find the weaknesses)

For your best theorem, the Critic must:
- Identify the strongest assumption that could be weakened
- Construct a boundary case: where does the result break down?
- If possible, state a `conjecture` for the generalized version and
  explain what would need to change in the proof

This is NOT optional. A theorem without a critique is incomplete.

### STEP 4: Anti-patterns (reject these)

These tactics indicate trivial proofs:
- `native_decide` / `decide` / `norm_num` / `rfl` -- unless genuinely proving a numeric fact
- `simp only []` with no simp set specified
- `sorry` on any theorem declared as `proved`

`omega`, `linarith`, and `Aesop` are fine for supporting lemmas.
`sorry` is fine for conjectures, generalizations, and boundary cases.

### STEP 5: Novelty

Your theorems must be genuinely new. If a statement appears in a textbook,
generalize it. If you cannot formalize a concept rigorously, pick a different topic.

### STEP 6: TAKE GOOD NOTES (first-class deliverables)

Your notes determine what the next research team investigates. They are NOT
an afterthought. They are your most important output after the proofs themselves.

**6a. Lab Notebook** (in each .lean file, as `-- !-- Lab Notebook -- !--` blocks):

For each major theorem, include a Lab Notebook comment block:
```lean
-- !-- Lab Notebook: cantorPairing_bijection -- !--
-- !-- Hypothesis: Cantor pairing is bijective because both surjective and injective -- !--
-- !-- Result: Proved via composition of surjective and injective proofs -- !--
-- !-- Insight: The constructive inverse of surjectivity is key; diagonal argument handles injectivity -- !--
-- !-- Failure analysis: Initial attempt to prove bijection directly failed; decomposition into surjective+injective was necessary -- !--
-- !-- End Lab Notebook -- !--
```

**6b. FUTURE_DIRECTIONS.md** (MANDATORY — your output WILL BE REJECTED if missing):

You MUST produce a FUTURE_DIRECTIONS.md file with this EXACT structure.
Copy the section headers below verbatim. Do NOT use freeform prose.

## Synthesis

[2-3 paragraphs: what did this cycle discover? What failed and why? What
structural insight emerged? Tie the directions together into a narrative.]

## Results Summary

[For EACH theorem: name, status (proved/conjecture/disproved), one-sentence
significance. Format as a bullet list:]

- `theoremName`: status — one-sentence significance

## Research Directions

### Direction 1: [Concise title]
**Hypothesis**: A precise, falsifiable mathematical statement.
**Test**: What experiment (proof/disproof/computation) would confirm or refute it.
**Why now**: What from THIS cycle makes this tractable.
**If true**: What new territory this opens.
**If false**: What the failure teaches us.

[Repeat for 3-5 directions]

IMPORTANT: The ## Synthesis and ## Results Summary sections are NOT optional.
If your FUTURE_DIRECTIONS.md is missing either section, it will be treated as
incomplete and the next research team will have no context to build on your work.

### STEP 7: Generalization loop

For your BEST theorem, attempt one level of generalization:
- State a stronger version (can use sorry if proving would take too long)
- Identify the boundary: where does the result break down?
- If the generalization is itself interesting, mark it as a `conjecture`
  in your theorem declarations and explain it in FUTURE_DIRECTIONS.md

### Output format

Your output must include:
1. `.lean` files with proofs and Lab Notebook blocks (structured as declared in Step 1)
2. `FUTURE_DIRECTIONS.md` with Synthesis, Results Summary, and 3-5 research
   directions (structured as in Step 6b)

Both are required. A cycle with proofs but no Lab Notebook or
FUTURE_DIRECTIONS.md is a cycle where the next team starts from scratch.
Take good notes.


## Output format reminder

Your output must include `.lean` files AND a `FUTURE_DIRECTIONS.md` file.
The .lean files contain the proofs. The FUTURE_DIRECTIONS.md contains 3-5
research conjectures that extend the work. Both are required.
Be precise, be deep, be world-class.
