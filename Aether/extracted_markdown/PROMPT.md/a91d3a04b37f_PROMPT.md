
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

**Title**: Small but fully verified core of the **Thermodynamic Pr
**Domain**: Novelty
**Mathematical framing**: # Future Directions: Thermodynamic Proof Complexity

This cycle established a small but fully verified core of the **Thermodynamic Proof
System** (TPS) framework in `MachineLearning/ThermodynamicProofComplexity.lean`. We
model the minimal proof length of a statement in bits and define its thermodynamic
cost as `tcost T n = T · ln 2 · n`, the Landauer work of erasing `n` bits at
temperature `T`. The verified results are:

- `tcost_step` — consecutive cost levels are separated by *exactly* one Landauer
  quantum `T · ln 2`;
- `tcost_strictMono` — cost is strictly increasing in proof length;
- `tcost_unbounded` — a Chaitin-type statement: no energy budget bounds all levels;
- `compressible_image_lt` / `incompressible_exists` — a pigeonhole incompressibility
  theorem: fewer than `2^n` strings have a description of length `< n`, so an
  incompressible (maximally expensive) string always exists;
- `expensive_incompressible` — the capstone: for any budget there is an incompressible
  string whose thermodynamic cost exceeds it;
- `thermodynamic_sorting_bound` — the sorting–proof bridge: comparison sorting costs at
  least `T · ln (n!)` of thermodynamic work.

The following directions are concrete, testable, and falsifiable extensions.

---

## Direction 1: Tight incompressibility fraction, not just existence

**Conjecture.** The current `compressible_image_lt` only counts codes of length `< n`.
Strengthen it to a *quantitative density* statement: for any decoder reading codes of
length `≤ n - c`, the fraction of length-`n` strings that are reproducible is at most
`2^{1-c}`. Formally, the compressible set has cardinality `≤ 2^{n-c+1} - 1`, so the
incompressible fraction is `≥ 1 - 2^{1-c}`.

**The key insight is** that the count of *all* descriptions shorter than a threshold is a
finite geometric sum `2^0 + ... + 2^{n-c} = 2^{n-c+1} - 1`, which is a vanishing fraction
of `2^n` as `c` grows — incompressibility is not a boundary curiosity but the generic case.

**Test.** Enumerate decoders on small `n ≤ 12`, count reproducible strings, and check the
empirical fraction against `2^{1-c}`. If the observed compressible fraction ever exceeds
`2^{1-c}` for a valid prefix-free decoder, the conjecture is refuted.

**Why now?** The existence proof (`incompressible_exists`) already isolates the exact
pigeonhole counting lemma; upgrading `<` to a geometric-sum cardinality bound is a direct,
self-contained refinement that needs no new Mathlib infrastructure.

---

## Direction 2: A thermodynamic complexity zoo with provable separations

**Conjecture.** Define cost classes `TPS[f] = { φ : tcost T (len φ) ≤ f(|φ|) }`. Then the
hierarchy is *strict*: for any `f` there is a statement in `TPS[f · ω]` but not `TPS[f]`,
where `ω` is any unbounded function. The Landauer step `tcost_step` makes the separation
exactly `T · ln 2` per bit, so cost classes are linearly ordered with no collapse.

**The key insight is** that `tcost_strictMono` plus `tcost_unbounded` already give a fully
ordered, gapless, unbounded cost spectrum — the raw material of a complexity zoo — and the
separations are *exact* multiples of `T · ln 2`, unlike asymptotic computational classes.

**Test.** Instantiate `len` from a concrete encoding (e.g. propositional tautologies vs.
arithmetic statements) and check that the minimal-length functions diverge. If two encodings
yield cost functions with bounded ratio, that pair fails to separate.

**Why now?** The ordered hierarchy is verified; the remaining step is to attach concrete
`len` functions to two proof systems and compare growth rates — a finite, computable task.

---

## Direction 3: Sorting is the first member of a "work lower bound" family

**Conjecture.** `thermodynamic_sorting_bound` generalizes from sorting to any
*comparison-based decision task* with `k` outcomes: distinguishing `k` outcomes needs
`k ≤ 2^comparisons`, hence work `≥ T · ln k`. Sorting (`k = n!`), searching (`k = n`), and
selection (`k = binomial(n, j)`) are instances of one theorem `decision_work_bound`.

**The key insight is** that the proof of the sorting bound never used factorials — only
`k ≤ 2^comparisons` and monotonicity of `log` — so the factorial can be replaced by an
arbitrary leaf count, unifying many algorithmic lower bounds under a single thermodynamic law.

**Test.** Specialize the general bound to `k = n` and `k = binomial(n, j)`; compare against
the known information-theoretic lower bounds for searching and selection. A mismatch by more
than the `ln 2` rounding gap refutes the generalization.

**Why now?** The sorting proof is already parametric in everything but the value `n!`;
abstracting that constant to a hypothesis `k ≤ 2^comparisons` is a one-line generalization
that immediately yields a reusable cross-domain lemma.

---

## Direction 4: Energy landscape ruggedness from Hamming geometry

**Conjecture.** Define `E(s) = ` Hamming distance from `s` to the nearest valid proof. The
number of strict local minima of `E` on `{0,1}^n` (well-formed but invalid strings at
Hamming distance `≥ 2` from every valid proof) grows exponentially in `n` whenever the valid
set is sparse — the regime guaranteed by `incompressible_exists`.

**The key insight is** that incompressibility forces valid proofs to be sparse and spread out
in the Hamming cube, so almost every string sits far from any valid proof and acts as a trap —
turning the abstract "incompressibility" theorem into a concrete statement about search landscapes.

**Test.** For `n ≤ 15`, enumerate all strings, mark valid proofs (from a toy resolution
system), compute `E`, and count local minima. Fit `a · c^n`. If `c ≤ 1`, refuted.

**Why now?** `compressible_image_lt` gives a verified upper bound on the size of the valid set,
which is exactly the input a counting argument for local minima needs; the landscape statement
is the natural geometric shadow of the counting theorem already proved.

---

## Direction 5: Quantum proofs save at most a polynomial factor of work

**Conjecture.** Extend `System` to a quantum TPS whose proof strings are density matrices on
`{0,1}^n`. Then `tcost_quantum(φ) ≥ tcost_classical(φ) / poly(|φ|)`: quantum mechanics buys at
most a polynomial reduction in thermodynamic proof cost.

**The key insight is** that Holevo's theorem caps the classical information extractable from a
quantum proof at `n` bits, so the verifier still pays Landauer cost for each extracted
certificate bit — the incompressibility counting that drives `expensive_incompressible` should
survive quantization with only a polynomial loss.

**Test.** Pick a family (e.g. graph non-isomorphism) with exponential classical and polynomial
quantum proof length; compute the cost ratio. If it exceeds every polynomial, refuted —
identifying a domain of genuine quantum thermodynamic advantage.

**Why now?** The classical core (`tcost`, `incompressible_exists`, `expensive_incompressible`)
is verified and fully parametric in the proof-string type, so swapping in quantum proof objects
is a structurally clean extension rather than a rebuild.

**Concept description**: # Future Directions: Thermodynamic Proof Complexity

This cycle established a small but fully verified core of the **Thermodynamic Proof
System** (TPS) framework in `MachineLearning/ThermodynamicProofComplexity.lean`. We
model the minimal proof length of a statement in bits and define its thermodynamic
cost as `tcost T n = T · ln 2 · n`, the Landauer work of erasing `n` bits at
temperature `T`. The verified results are:

- `tcost_step` — consecutive cost levels are separated by *exactly* one Landauer
  quantum `T · ln 2`;
- `tcost_strictMono` — cost is strictly increasing in proof length;
- `tcost_unbounded` — a Chaitin-type statement: no energy budget bounds all levels;
- `compressible_image_lt` / `incompressible_exists` — a pigeonhole incompressibility
  theorem: fewer than `2^n` strings have a description of length `< n`, so an
  incompressible (maximally expensive) string always exists;
- `expensive_incompressible` — the capstone: for any budget there is an incompressible
  string whose thermodynamic cost exceeds it;
- `thermodynamic_sorting_bound` — the sorting–proof bridge: comparison sorting costs at
  least `T · ln (n!)` of thermodynamic work.

The following directions are concrete, testable, and falsifiable extensions.

---

## Direction 1: Tight incompressibility fraction, not just existence

**Conjecture.** The current `compressible_image_lt` only counts codes of length `< n`.
Strengthen it to a *quantitative density* statement: for any decoder reading codes of
length `≤ n - c`, the fraction of length-`n` strings that are reproducible is at most
`2^{1-c}`. Formally, the compressible set has cardinality `≤ 2^{n-c+1} - 1`, so the
incompressible fraction is `≥ 1 - 2^{1-c}`.

**The key insight is** that the count of *all* descriptions shorter than a threshold is a
finite geometric sum `2^0 + ... + 2^{n-c} = 2^{n-c+1} - 1`, which is a vanishing fraction
of `2^n` as `c` grows — incompressibility is not a boundary curiosity but the generic case.

**Test.** Enumerate decoders on small `n ≤ 12`, count reproducible strings, and check the
empirical fraction against `2^{1-c}`. If the observed compressible fraction ever exceeds
`2^{1-c}` for a valid prefix-free decoder, the conjecture is refuted.

**Why now?** The existence proof (`incompressible_exists`) already isolates the exact
pigeonhole counting lemma; upgrading `<` to a geometric-sum cardinality bound is a direct,
self-contained refinement that needs no new Mathlib infrastructure.

---

## Direction 2: A thermodynamic complexity zoo with provable separations

**Conjecture.** Define cost classes `TPS[f] = { φ : tcost T (len φ) ≤ f(|φ|) }`. Then the
hierarchy is *strict*: for any `f` there is a statement in `TPS[f · ω]` but not `TPS[f]`,
where `ω` is any unbounded function. The Landauer step `tcost_step` makes the separation
exactly `T · ln 2` per bit, so cost classes are linearly ordered with no collapse.

**The key insight is** that `tcost_strictMono` plus `tcost_unbounded` already give a fully
ordered, gapless, unbounded cost spectrum — the raw material of a complexity zoo — and the
separations are *exact* multiples of `T · ln 2`, unlike asymptotic computational classes.

**Test.** Instantiate `len` from a concrete encoding (e.g. propositional tautologies vs.
arithmetic statements) and check that the minimal-length functions diverge. If two encodings
yield cost functions with bounded ratio, that pair fails to separate.

**Why now?** The ordered hierarchy is verified; the remaining step is to attach concrete
`len` functions to two proof systems and compare growth rates — a finite, computable task.

---

## Direction 3: Sorting is the first member of a "work lower bound" family

**Conjecture.** `thermodynamic_sorting_bound` generalizes from sorting to any
*comparison-based decision task* with `k` outcomes: distinguishing `k` outcomes needs
`k ≤ 2^comparisons`, hence work `≥ T · ln k`. Sorting (`k = n!`), searching (`k = n`), and
selection (`k = binomial(n, j)`) are instances of one theorem `decision_work_bound`.

**The key insight is** that the proof of the sorting bound never used factorials — only
`k ≤ 2^comparisons` and monotonicity of `log` — so the factorial can be replaced by an
arbitrary leaf count, unifying many algorithmic lower bounds under a single thermodynamic law.

**Test.** Specialize the general bound to `k = n` and `k = binomial(n, j)`; compare against
the known information-theoretic lower bounds for searching and selection. A mismatch by more
than the `ln 2` rounding gap refutes the generalization.

**Why now?** The sorting proof is already parametric in everything but the value `n!`;
abstracting that constant to a hypothesis `k ≤ 2^comparisons` is a one-line generalization
that immediately yields a reusable cross-domain lemma.

---

## Direction 4: Energy landscape ruggedness from Hamming geometry

**Conjecture.** Define `E(s) = ` Hamming distance from `s` to the nearest valid proof. The
number of strict local minima of `E` on `{0,1}^n` (well-formed but invalid strings at
Hamming distance `≥ 2` from every valid proof) grows exponentially in `n` whenever the valid
set is sparse — the regime guaranteed by `incompressible_exists`.

**The key insight is** that incompressibility forces valid proofs to be sparse and spread out
in the Hamming cube, so almost every string sits far from any valid proof and acts as a trap —
turning the abstract "incompressibility" theorem into a concrete statement about search landscapes.

**Test.** For `n ≤ 15`, enumerate all strings, mark valid proofs (from a toy resolution
system), compute `E`, and count local minima. Fit `a · c^n`. If `c ≤ 1`, refuted.

**Why now?** `compressible_image_lt` gives a verified upper bound on the size of the valid set,
which is exactly the input a counting argument for local minima needs; the landscape statement
is the natural geometric shadow of the counting theorem already proved.

---

## Direction 5: Quantum proofs save at most a polynomial factor of work

**Conjecture.** Extend `System` to a quantum TPS whose proof strings are density matrices on
`{0,1}^n`. Then `tcost_quantum(φ) ≥ tcost_classical(φ) / poly(|φ|)`: quantum mechanics buys at
most a polynomial reduction in thermodynamic proof cost.

**The key insight is** that Holevo's theorem caps the classical information extractable from a
quantum proof at `n` bits, so the verifier still pays Landauer cost for each extracted
certificate bit — the incompressibility counting that drives `expensive_incompressible` should
survive quantization with only a polynomial loss.

**Test.** Pick a family (e.g. graph non-isomorphism) with exponential classical and polynomial
quantum proof length; compute the cost ratio. If it exceeds every polynomial, refuted —
identifying a domain of genuine quantum thermodynamic advantage.

**Why now?** The classical core (`tcost`, `incompressible_exists`, `expensive_incompressible`)
is verified and fully parametric in the proof-string type, so swapping in quantum proof objects
is a structurally clean extension rather than a rebuild.

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
