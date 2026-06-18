
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

**Title**: This cycle took the catalog's well-developed theory of the Fibonacci **rank of
**Domain**: Novelty
**Mathematical framing**: # Future Directions — Fibonacci Rank of Apparition as a Lattice Morphism

## Synthesis

This cycle took the catalog's well-developed theory of the Fibonacci **rank of
apparition** `z(m) = apparitionRank m` (the least `k > 0` with `m ∣ F k`, proved to
exist unconditionally for every `m ≥ 1` in `Catalog/Novelty/FibApparitionExistence.lean`,
together with the characterization `m ∣ F n ↔ z(m) ∣ n`) and asked a structural
question: *how does `z` interact with the divisibility lattice on moduli?*

The central discovery is that `z` is a **join-morphism**: `z(lcm a b) = lcm(z a, z b)`
for **all** positive `a, b`. This strictly generalizes the catalog's earlier *coprime*
multiplicativity `z(a·b) = lcm(z a, z b)` (which is only the `gcd a b = 1` special case,
where `lcm a b = a·b`). The proof is conceptually clean: the characterization says the
"appearance set" of `m` is exactly the multiples of `z(m)`, so taking `lcm` of moduli
*intersects* appearance sets, and the intersection of two sets-of-multiples is the
set-of-multiples of the `lcm`. We isolated this as `rankFunction_lcm_abstract`, which
shows the join law is *purely formal* — it depends only on the "appearance ↔ rank
divides index" pattern and not on Fibonacci numbers at all.

The Critic phase produced the most informative negative result: the dual **meet-law
fails**. `z(gcd a b) = gcd(z a, z b)` is false, witnessed by `a = 2, b = 17`
(coprime, so `z(gcd) = z(1) = 1`, yet `gcd(z 2, z 17) = gcd(3, 9) = 3`). The structural
reason is sharp: `gcd(a,b) ∣ F n` is *not* a Boolean combination of `a ∣ F n` and
`b ∣ F n`, whereas `lcm(a,b) ∣ F n` *is* (it is their conjunction). So `z` respects the
operation that corresponds to "and" on appearance, but not the one that would need "or".
This asymmetry is the organizing insight for the directions below.

## Results Summary

- `apparitionRank_eq`: proved — pins down `z(m)` from a minimal witness; the
  computational workhorse for evaluating concrete ranks.
- `apparitionRank_lcm`: proved — **main result**, `z(lcm a b) = lcm(z a, z b)` for all
  positive `a, b`; generalizes the catalog's coprime multiplicativity.
- `apparitionRank_dvd_of_dvd`: proved — `z` is monotone for divisibility
  (`a ∣ b → z a ∣ z b`), an immediate corollary of the join law.
- `apparitionRank_one`, `apparitionRank_two`, `apparitionRank_seventeen`: proved —
  concrete ranks `z 1 = 1`, `z 2 = 3`, `z 17 = 9`.
- `apparitionRank_meet_fails`: proved (disproof) — explicit counterexample showing
  `z` is **not** a meet-morphism; a join-but-not-meet lattice map.
- `rankFunction_lcm_abstract`: proved — the join law holds for any abstract
  appearance/rank system, decoupling it from Fibonacci specifics.

## Research Directions

### Direction 1: Transport the join law to other strong divisibility sequences
**Hypothesis**: For the base-`a` Mersenne/repunit sequence `u n = aⁿ − 1`, the rank of
apparition `w(m)` (least `k > 0` with `m ∣ aᵏ − 1`, i.e. the multiplicative order of `a`
mod `m`) satisfies `w(lcm p q) = lcm(w p, w q)` for moduli coprime to `a`.
**Test**: Instantiate `rankFunction_lcm_abstract` with `appears m n := m ∣ aⁿ − 1` and
the order function, after proving the characterization `m ∣ aⁿ − 1 ↔ ord_m(a) ∣ n`
(Mathlib's `ZMod.orderOf` / `Nat.pow_sub_one`...). The abstract lemma then closes it.
**Why now**: `rankFunction_lcm_abstract` already exists and asks for exactly two inputs;
the catalog's `StrongDivSeq` file (`FibonacciEntryPointInvariant.lean`) already supplies
the Mersenne gcd identity `gcd(aᵐ−1, aⁿ−1) = a^{gcd m n}−1`, half the needed machinery.
**If true**: A single abstract theorem unifies the apparition-lattice structure of
Fibonacci numbers and of multiplicative orders — a genuine cross-domain bridge.
**If false**: It would reveal that the order function lacks the clean appearance
characterization, pinpointing where the "set of multiples" picture degrades.

### Direction 2: Characterize exactly when the meet-law holds
**Hypothesis**: `z(gcd a b) = gcd(z a, z b)` holds **iff** `z a ∣ z b` or `z b ∣ z a`
(i.e. the ranks are `∣`-comparable).
**Test**: Prove the `⇐` direction from the join law plus `apparitionRank_dvd_of_dvd`;
search computationally (with `apparitionRank_eq`) for a comparable-rank pair where it
*fails*, or an incomparable pair where it *holds*, to settle `⇒`.
**Why now**: This cycle produced both a clean failure (`a=2,b=17`, incomparable ranks
`3,9`... note `3 ∣ 9`, so the naive guess needs refinement!) and the exact tools
(`apparitionRank_eq`, the join law) to test boundary cases rapidly.
**If true**: Completes the lattice picture — `z` becomes a morphism precisely on chains.
**If false**: The counterexample (note `gcd(2,17)`: ranks `3,9` ARE comparable yet the
law fails, so the hypothesis as stated is likely refuted) will force a finer invariant,
probably involving how `gcd(a,b)` factors relative to `a` and `b`.

### Direction 3: Prime-power reduction and Wall's question
**Hypothesis**: `z(pᵉ) = p^{max(0, e − e₀)} · z(p)` where `e₀` is the `p`-adic valuation
of `F_{z(p)}`; combined with the join law this reduces *all* rank computation to primes.
**Test**: Prove `z(p) ∣ z(pᵉ)` and `z(pᵉ) ∣ pᵉ⁻¹ · z(p)` using LTE (lifting-the-exponent)
for Fibonacci numbers, which the catalog already has
(`Catalog/Shared/FibonacciLTE.lean`). The exact power is Wall's question territory.
**Why now**: The join law (this cycle) plus existing LTE infrastructure means the only
missing piece is the prime-power case; everything composite then follows for free.
**If true**: A complete, computable description of `z` on all of ℕ from its values on
primes — the apparition analogue of the fundamental theorem of arithmetic.
**If false**: A Wall–Sun–Sun-type prime would be implicated; even a conditional proof
would sharpen the connection to that open problem.

### Direction 4: The appearance map as a poset embedding
**Hypothesis**: The map sending `m` to its appearance set `A(m) = {n | m ∣ F n}` is a
lattice homomorphism `(ℕ_{≥1}, lcm, ·) → (sets of multiples, ∩, ?)` that is *injective
modulo equal rank*: `A(a) = A(b) ↔ z a = z b`.
**Test**: Prove `A(m) = z(m)·ℕ` from the characterization, then `A(a) = A(b) ↔ z a = z b`
by `Nat.dvd_antisymm`. Investigate whether `A(a) ∪ A(b)` is ever again some `A(c)`
(it generally is not — this is the meet-law failure in set language).
**Why now**: `apparitionRank_meet_fails` is exactly the statement that appearance sets
are not closed under union; framing it set-theoretically makes the obstruction precise.
**If true**: Reframes the entire theory as the order-embedding `m ↦ z(m)ℕ`, clarifying
which set operations the embedding preserves.
**If false**: Would mean two moduli with different ranks share an appearance set,
contradicting the characterization — a sanity check that, if it failed, would expose a
bug in the rank theory.

### Direction 5: Pisano period divisibility
**Hypothesis**: `z(m) ∣ π(m)` for every `m ≥ 1`, where `π(m)` is the Pisano period
(the period of `F mod m`), and moreover `π(m)/z(m) ∈ {1, 2, 4}`.
**Test**: Build the Pisano period from the `fibStep` permutation already defined in
`FibApparitionExistence.lean` (its order on `(0,1)`), prove `m ∣ F_{π(m)}` to get
`z(m) ∣ π(m)` from the characterization, then analyze the quotient.
**Why now**: The pigeonhole/permutation argument that proved apparition *existence* this
cycle's foundation already constructs the periodicity; extracting the period `π(m)` is a
small additional step on the same `fibStep` machinery.
**If true**: Gives the first formal link between rank of apparition and Pisano period in
this library — neither concept currently exists in Mathlib.
**If false** (i.e. the quotient takes a value outside `{1,2,4}`): It would contradict a
classical theorem, almost certainly signaling an error in the Pisano-period formalization
rather than new mathematics — a valuable correctness probe.

**Concept description**: # Future Directions — Fibonacci Rank of Apparition as a Lattice Morphism

## Synthesis

This cycle took the catalog's well-developed theory of the Fibonacci **rank of
apparition** `z(m) = apparitionRank m` (the least `k > 0` with `m ∣ F k`, proved to
exist unconditionally for every `m ≥ 1` in `Catalog/Novelty/FibApparitionExistence.lean`,
together with the characterization `m ∣ F n ↔ z(m) ∣ n`) and asked a structural
question: *how does `z` interact with the divisibility lattice on moduli?*

The central discovery is that `z` is a **join-morphism**: `z(lcm a b) = lcm(z a, z b)`
for **all** positive `a, b`. This strictly generalizes the catalog's earlier *coprime*
multiplicativity `z(a·b) = lcm(z a, z b)` (which is only the `gcd a b = 1` special case,
where `lcm a b = a·b`). The proof is conceptually clean: the characterization says the
"appearance set" of `m` is exactly the multiples of `z(m)`, so taking `lcm` of moduli
*intersects* appearance sets, and the intersection of two sets-of-multiples is the
set-of-multiples of the `lcm`. We isolated this as `rankFunction_lcm_abstract`, which
shows the join law is *purely formal* — it depends only on the "appearance ↔ rank
divides index" pattern and not on Fibonacci numbers at all.

The Critic phase produced the most informative negative result: the dual **meet-law
fails**. `z(gcd a b) = gcd(z a, z b)` is false, witnessed by `a = 2, b = 17`
(coprime, so `z(gcd) = z(1) = 1`, yet `gcd(z 2, z 17) = gcd(3, 9) = 3`). The structural
reason is sharp: `gcd(a,b) ∣ F n` is *not* a Boolean combination of `a ∣ F n` and
`b ∣ F n`, whereas `lcm(a,b) ∣ F n` *is* (it is their conjunction). So `z` respects the
operation that corresponds to "and" on appearance, but not the one that would need "or".
This asymmetry is the organizing insight for the directions below.

## Results Summary

- `apparitionRank_eq`: proved — pins down `z(m)` from a minimal witness; the
  computational workhorse for evaluating concrete ranks.
- `apparitionRank_lcm`: proved — **main result**, `z(lcm a b) = lcm(z a, z b)` for all
  positive `a, b`; generalizes the catalog's coprime multiplicativity.
- `apparitionRank_dvd_of_dvd`: proved — `z` is monotone for divisibility
  (`a ∣ b → z a ∣ z b`), an immediate corollary of the join law.
- `apparitionRank_one`, `apparitionRank_two`, `apparitionRank_seventeen`: proved —
  concrete ranks `z 1 = 1`, `z 2 = 3`, `z 17 = 9`.
- `apparitionRank_meet_fails`: proved (disproof) — explicit counterexample showing
  `z` is **not** a meet-morphism; a join-but-not-meet lattice map.
- `rankFunction_lcm_abstract`: proved — the join law holds for any abstract
  appearance/rank system, decoupling it from Fibonacci specifics.

## Research Directions

### Direction 1: Transport the join law to other strong divisibility sequences
**Hypothesis**: For the base-`a` Mersenne/repunit sequence `u n = aⁿ − 1`, the rank of
apparition `w(m)` (least `k > 0` with `m ∣ aᵏ − 1`, i.e. the multiplicative order of `a`
mod `m`) satisfies `w(lcm p q) = lcm(w p, w q)` for moduli coprime to `a`.
**Test**: Instantiate `rankFunction_lcm_abstract` with `appears m n := m ∣ aⁿ − 1` and
the order function, after proving the characterization `m ∣ aⁿ − 1 ↔ ord_m(a) ∣ n`
(Mathlib's `ZMod.orderOf` / `Nat.pow_sub_one`...). The abstract lemma then closes it.
**Why now**: `rankFunction_lcm_abstract` already exists and asks for exactly two inputs;
the catalog's `StrongDivSeq` file (`FibonacciEntryPointInvariant.lean`) already supplies
the Mersenne gcd identity `gcd(aᵐ−1, aⁿ−1) = a^{gcd m n}−1`, half the needed machinery.
**If true**: A single abstract theorem unifies the apparition-lattice structure of
Fibonacci numbers and of multiplicative orders — a genuine cross-domain bridge.
**If false**: It would reveal that the order function lacks the clean appearance
characterization, pinpointing where the "set of multiples" picture degrades.

### Direction 2: Characterize exactly when the meet-law holds
**Hypothesis**: `z(gcd a b) = gcd(z a, z b)` holds **iff** `z a ∣ z b` or `z b ∣ z a`
(i.e. the ranks are `∣`-comparable).
**Test**: Prove the `⇐` direction from the join law plus `apparitionRank_dvd_of_dvd`;
search computationally (with `apparitionRank_eq`) for a comparable-rank pair where it
*fails*, or an incomparable pair where it *holds*, to settle `⇒`.
**Why now**: This cycle produced both a clean failure (`a=2,b=17`, incomparable ranks
`3,9`... note `3 ∣ 9`, so the naive guess needs refinement!) and the exact tools
(`apparitionRank_eq`, the join law) to test boundary cases rapidly.
**If true**: Completes the lattice picture — `z` becomes a morphism precisely on chains.
**If false**: The counterexample (note `gcd(2,17)`: ranks `3,9` ARE comparable yet the
law fails, so the hypothesis as stated is likely refuted) will force a finer invariant,
probably involving how `gcd(a,b)` factors relative to `a` and `b`.

### Direction 3: Prime-power reduction and Wall's question
**Hypothesis**: `z(pᵉ) = p^{max(0, e − e₀)} · z(p)` where `e₀` is the `p`-adic valuation
of `F_{z(p)}`; combined with the join law this reduces *all* rank computation to primes.
**Test**: Prove `z(p) ∣ z(pᵉ)` and `z(pᵉ) ∣ pᵉ⁻¹ · z(p)` using LTE (lifting-the-exponent)
for Fibonacci numbers, which the catalog already has
(`Catalog/Shared/FibonacciLTE.lean`). The exact power is Wall's question territory.
**Why now**: The join law (this cycle) plus existing LTE infrastructure means the only
missing piece is the prime-power case; everything composite then follows for free.
**If true**: A complete, computable description of `z` on all of ℕ from its values on
primes — the apparition analogue of the fundamental theorem of arithmetic.
**If false**: A Wall–Sun–Sun-type prime would be implicated; even a conditional proof
would sharpen the connection to that open problem.

### Direction 4: The appearance map as a poset embedding
**Hypothesis**: The map sending `m` to its appearance set `A(m) = {n | m ∣ F n}` is a
lattice homomorphism `(ℕ_{≥1}, lcm, ·) → (sets of multiples, ∩, ?)` that is *injective
modulo equal rank*: `A(a) = A(b) ↔ z a = z b`.
**Test**: Prove `A(m) = z(m)·ℕ` from the characterization, then `A(a) = A(b) ↔ z a = z b`
by `Nat.dvd_antisymm`. Investigate whether `A(a) ∪ A(b)` is ever again some `A(c)`
(it generally is not — this is the meet-law failure in set language).
**Why now**: `apparitionRank_meet_fails` is exactly the statement that appearance sets
are not closed under union; framing it set-theoretically makes the obstruction precise.
**If true**: Reframes the entire theory as the order-embedding `m ↦ z(m)ℕ`, clarifying
which set operations the embedding preserves.
**If false**: Would mean two moduli with different ranks share an appearance set,
contradicting the characterization — a sanity check that, if it failed, would expose a
bug in the rank theory.

### Direction 5: Pisano period divisibility
**Hypothesis**: `z(m) ∣ π(m)` for every `m ≥ 1`, where `π(m)` is the Pisano period
(the period of `F mod m`), and moreover `π(m)/z(m) ∈ {1, 2, 4}`.
**Test**: Build the Pisano period from the `fibStep` permutation already defined in
`FibApparitionExistence.lean` (its order on `(0,1)`), prove `m ∣ F_{π(m)}` to get
`z(m) ∣ π(m)` from the characterization, then analyze the quotient.
**Why now**: The pigeonhole/permutation argument that proved apparition *existence* this
cycle's foundation already constructs the periodicity; extracting the period `π(m)` is a
small additional step on the same `fibStep` machinery.
**If true**: Gives the first formal link between rank of apparition and Pisano period in
this library — neither concept currently exists in Mathlib.
**If false** (i.e. the quotient takes a value outside `{1,2,4}`): It would contradict a
classical theorem, almost certainly signaling an error in the Pisano-period formalization
rather than new mathematics — a valuable correctness probe.

**Novelty estimate**: 0.75
**Breakthrough potential**: 0.75
Research domain: Novelty
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
