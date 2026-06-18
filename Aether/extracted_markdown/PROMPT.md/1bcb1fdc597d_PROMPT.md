
            ## PHASE A: LEAN 4 ONLY — DOING THE MATH

            You are a world-class mathematician. Your ONLY job in this cycle is
to produce **new Lean 4 code that extends the frontier of mathematics**.

            ### DELIVERABLES (strict — only this):
            1. **lean files (count chosen by the Plan)**
            2. **2-4 theorems with correct proofs (sorry = 0 on main results)**
            3. **Brief proof sketches** as `-- !-- comment -- !--` blocks (1-2 sentences each)
            4. **A FUTURE_DIRECTIONS.md file** listing 3-5 testable, falsifiable
               conjectures as a freeform narrative (NOT a form). Each direction MUST
               include a "The key insight is..." sentence and a "Why now?" justification.
               This file drives the next research cycle — make it count.

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

**Title**: This cycle closed the satisfiable side of the first-moment picture for random
**Domain**: Novelty
**Mathematical framing**: # Future Directions — Proof Phase Transitions in Random k-SAT

This cycle closed the satisfiable side of the first-moment picture for random
`k`-SAT. The file `RandomKSAT.lean` already contained the *annealed upper bound*
(`exists_unsat`, `exists_unsat_of_real_density`): once the average number of
satisfying assignments `2^n·(1 − 2^{−k})^m` drops below `1`, an unsatisfiable
formula must exist. We added the **matching lower bracket**:

* `exists_sat_general` / `exists_many_sat_general` — an abstract averaging
  (max ≥ mean) law on the very same first-moment identity `first_moment_general`,
  valid for *any* finite CSP;
* `exists_sat_count_ge`, `exists_sat`, and `exists_sat_of_real_density` — their
  Boolean specializations, culminating in: if `1 ≤ 2^n·(1 − 2^{−k})^m` then a
  *satisfiable* formula provably exists.

Together with the existing unsat results, the satisfiability transition is now
formally **bracketed** at the statistical-physics density
`2^n·(1 − 2^{−k})^m = 1`: below it some formula is unsatisfiable, at/above it some
formula is satisfiable. The arguments are pure averaging/pigeonhole on a single
exact counting identity, which makes them unusually robust and easy to transport
to other constraint models (the `Qary` namespace already demonstrates this for the
`q`-ary model). The following directions push the same exact-counting engine
further.

## Direction 1 — A two-sided density window theorem as a single statement

We currently expose the lower and upper brackets as separate theorems. The next
step is one packaged statement `sat_phase_window`: for `1 ≤ n` and a real density
`d := 2^n·(1 − 2^{−k})^m`, *both* a satisfiable and an unsatisfiable formula exist
whenever `d` sits in the half-open transition window, and the `m ↦ d` map is
strictly antitone so the window is hit by exactly one critical clause count
`m*(n,k)`. The key insight is that the satisfiable and unsatisfiable existence
proofs both factor through the *same* incidence sum `∑_F #{a ⊨ F} = |A|·S^m`, so
the window is governed by a single scalar crossing `1`, not by two independent
phenomena. Why now? Both halves are already proved in `RandomKSAT.lean`, and
`exists_unsat_of_density_mono` already supplies the antitonicity; assembling them
needs only the integer-monotonicity of `m ↦ 2^n·((2n)^k − n^k)^m`, which is
within reach of the existing casting lemmas.

## Direction 2 — Second-moment lower bound on the satisfiable side

The first moment only certifies *existence* of a satisfiable formula; the famous
strengthening is a second-moment / variance bound showing that a *positive
fraction* of formulas are satisfiable in the dense regime. Concretely, prove
`second_moment_general`: `∑_F (#{a ⊨ F})^2 = ∑_{a,b} (sat-overlap of a,b)^m`,
then apply Paley–Zygmund to lower-bound `#{F : #{a ⊨ F} > 0}`. The key insight is
that the second moment again factorizes coordinatewise over the `m` independent
constraint slots — exactly like `card_models_form` did for the first moment — so
the entire variance computation reduces to one per-pair overlap count
`#{c : sat a c ∧ sat b c}`, a finite combinatorial quantity. Why now? The
factorization infrastructure (`card_models_form`, `first_moment_general`) is
already in place and is the only nontrivial ingredient; the second moment reuses
it verbatim with a pair `(a,b)` in place of a single `a`.

## Direction 3 — Exact satisfiability for the planted / 1-in-k variants

The same incidence identity holds for *any* satisfaction relation, so it applies
unchanged to the 1-in-k SAT model (a clause is satisfied iff *exactly one*
literal is true) and to NAE-SAT (not-all-equal). For 1-in-k the per-assignment
satisfied-clause count is `S = k·n·(2n)^{k−1} − …` (a clean inclusion–exclusion
constant), and the existence thresholds drop out of `exists_unsat_general` /
`exists_many_sat_general` with no new proof effort. The key insight is that our
abstract law is indifferent to *which* clauses are deemed satisfied: only the
single number `S = #{c : sat a c}` (constant in `a` by symmetry) enters, so a new
model is fully specified by recomputing one cardinality. Why now? The abstract
generals are already model-agnostic and proven; each new model is a self-contained
`card_*_clause` lemma plus a one-line specialization, ideal for parallel
formalization.

## Direction 4 — Sharpness: the brackets are tight at the endpoints

We should certify that neither bracket can be improved by a constant factor, by
exhibiting explicit witnesses. The key insight is that the averaging inequality
`|A|·S^m ≤ |C|^m·#{a ⊨ F}` becomes an *equality* exactly when every formula has
the same number of satisfying assignments, which happens degenerately at `k = 0`
or `m = 0`; classifying these equality cases pins down precisely where the
"max ≥ mean" step loses information. Why now? The equality analysis only requires
inspecting `Finset.sum_lt_sum_of_nonempty` (already used in
`exists_many_sat_general`) under the hypothesis that all summands are equal — a
boundary-case study that also doubles as the counterexample family the quality bar
asks for.

## Direction 5 — From "exists" to a quantitative satisfying-assignment count

The strongest form of the lower bracket is not "some formula is satisfiable" but
"some formula has at least `⌈2^n·(1 − 2^{−k})^m⌉` satisfying assignments", which
`exists_sat_count_ge` already encodes in multiplicative form. Turning this into an
explicit floor/ceiling bound `∃ F, ⌈mean⌉ ≤ #{a ⊨ F}` would give a formally
verified annealed *capacity* statement for random k-SAT. The key insight is that
the multiplicative inequality `|C|^m·#{a ⊨ F} ≥ |A|·S^m` is exactly the
division-free form of `#{a ⊨ F} ≥ mean`, so the upgrade is a `Nat`-division
manipulation (`Nat.le_div_iff_mul_le`) rather than any new combinatorics. Why now?
`exists_sat_count_ge` is proved and positivity of `(2n)^{km}` is already handled
in `exists_sat_of_real_density`, so the ceiling refinement is a short arithmetic
postprocessing step.

**Concept description**: # Future Directions — Proof Phase Transitions in Random k-SAT

This cycle closed the satisfiable side of the first-moment picture for random
`k`-SAT. The file `RandomKSAT.lean` already contained the *annealed upper bound*
(`exists_unsat`, `exists_unsat_of_real_density`): once the average number of
satisfying assignments `2^n·(1 − 2^{−k})^m` drops below `1`, an unsatisfiable
formula must exist. We added the **matching lower bracket**:

* `exists_sat_general` / `exists_many_sat_general` — an abstract averaging
  (max ≥ mean) law on the very same first-moment identity `first_moment_general`,
  valid for *any* finite CSP;
* `exists_sat_count_ge`, `exists_sat`, and `exists_sat_of_real_density` — their
  Boolean specializations, culminating in: if `1 ≤ 2^n·(1 − 2^{−k})^m` then a
  *satisfiable* formula provably exists.

Together with the existing unsat results, the satisfiability transition is now
formally **bracketed** at the statistical-physics density
`2^n·(1 − 2^{−k})^m = 1`: below it some formula is unsatisfiable, at/above it some
formula is satisfiable. The arguments are pure averaging/pigeonhole on a single
exact counting identity, which makes them unusually robust and easy to transport
to other constraint models (the `Qary` namespace already demonstrates this for the
`q`-ary model). The following directions push the same exact-counting engine
further.

## Direction 1 — A two-sided density window theorem as a single statement

We currently expose the lower and upper brackets as separate theorems. The next
step is one packaged statement `sat_phase_window`: for `1 ≤ n` and a real density
`d := 2^n·(1 − 2^{−k})^m`, *both* a satisfiable and an unsatisfiable formula exist
whenever `d` sits in the half-open transition window, and the `m ↦ d` map is
strictly antitone so the window is hit by exactly one critical clause count
`m*(n,k)`. The key insight is that the satisfiable and unsatisfiable existence
proofs both factor through the *same* incidence sum `∑_F #{a ⊨ F} = |A|·S^m`, so
the window is governed by a single scalar crossing `1`, not by two independent
phenomena. Why now? Both halves are already proved in `RandomKSAT.lean`, and
`exists_unsat_of_density_mono` already supplies the antitonicity; assembling them
needs only the integer-monotonicity of `m ↦ 2^n·((2n)^k − n^k)^m`, which is
within reach of the existing casting lemmas.

## Direction 2 — Second-moment lower bound on the satisfiable side

The first moment only certifies *existence* of a satisfiable formula; the famous
strengthening is a second-moment / variance bound showing that a *positive
fraction* of formulas are satisfiable in the dense regime. Concretely, prove
`second_moment_general`: `∑_F (#{a ⊨ F})^2 = ∑_{a,b} (sat-overlap of a,b)^m`,
then apply Paley–Zygmund to lower-bound `#{F : #{a ⊨ F} > 0}`. The key insight is
that the second moment again factorizes coordinatewise over the `m` independent
constraint slots — exactly like `card_models_form` did for the first moment — so
the entire variance computation reduces to one per-pair overlap count
`#{c : sat a c ∧ sat b c}`, a finite combinatorial quantity. Why now? The
factorization infrastructure (`card_models_form`, `first_moment_general`) is
already in place and is the only nontrivial ingredient; the second moment reuses
it verbatim with a pair `(a,b)` in place of a single `a`.

## Direction 3 — Exact satisfiability for the planted / 1-in-k variants

The same incidence identity holds for *any* satisfaction relation, so it applies
unchanged to the 1-in-k SAT model (a clause is satisfied iff *exactly one*
literal is true) and to NAE-SAT (not-all-equal). For 1-in-k the per-assignment
satisfied-clause count is `S = k·n·(2n)^{k−1} − …` (a clean inclusion–exclusion
constant), and the existence thresholds drop out of `exists_unsat_general` /
`exists_many_sat_general` with no new proof effort. The key insight is that our
abstract law is indifferent to *which* clauses are deemed satisfied: only the
single number `S = #{c : sat a c}` (constant in `a` by symmetry) enters, so a new
model is fully specified by recomputing one cardinality. Why now? The abstract
generals are already model-agnostic and proven; each new model is a self-contained
`card_*_clause` lemma plus a one-line specialization, ideal for parallel
formalization.

## Direction 4 — Sharpness: the brackets are tight at the endpoints

We should certify that neither bracket can be improved by a constant factor, by
exhibiting explicit witnesses. The key insight is that the averaging inequality
`|A|·S^m ≤ |C|^m·#{a ⊨ F}` becomes an *equality* exactly when every formula has
the same number of satisfying assignments, which happens degenerately at `k = 0`
or `m = 0`; classifying these equality cases pins down precisely where the
"max ≥ mean" step loses information. Why now? The equality analysis only requires
inspecting `Finset.sum_lt_sum_of_nonempty` (already used in
`exists_many_sat_general`) under the hypothesis that all summands are equal — a
boundary-case study that also doubles as the counterexample family the quality bar
asks for.

## Direction 5 — From "exists" to a quantitative satisfying-assignment count

The strongest form of the lower bracket is not "some formula is satisfiable" but
"some formula has at least `⌈2^n·(1 − 2^{−k})^m⌉` satisfying assignments", which
`exists_sat_count_ge` already encodes in multiplicative form. Turning this into an
explicit floor/ceiling bound `∃ F, ⌈mean⌉ ≤ #{a ⊨ F}` would give a formally
verified annealed *capacity* statement for random k-SAT. The key insight is that
the multiplicative inequality `|C|^m·#{a ⊨ F} ≥ |A|·S^m` is exactly the
division-free form of `#{a ⊨ F} ≥ mean`, so the upgrade is a `Nat`-division
manipulation (`Nat.le_div_iff_mul_le`) rather than any new combinatorics. Why now?
`exists_sat_count_ge` is proved and positivity of `(2n)^{km}` is already handled
in `exists_sat_of_real_density`, so the ceiling refinement is a short arithmetic
postprocessing step.

**Novelty estimate**: 0.75
**Breakthrough potential**: 0.75
Research domain: Novelty
Research mode: team




### Recent Discoveries in Catalog
No previous research cycles completed yet. This is a cold start — prioritize sorry_fill on the priority targets (CarmichaelComposite, Fib_gcd_identity) to close known open problems, or target cross-domain bridge theorems for novelty.


## v7 Depth Requirements — Structured Proofs with Completeness Gates

You are producing Lean 4 code on the mathematical frontier. Your output must
be COMPILABLE and your proofs must be COMPLETE. A single correct proof of a
non-trivial result is worth more than 5 theorems with `sorry`.

### STEP 1: THEOREM DECLARATIONS (required — before any code)

List every theorem you intend to prove. For each, state:
- **Name**: The Lean declaration name
- **Statement**: One-sentence informal statement
- **Status**: `proved` | `conjecture` | `proved_with_lemma_sorry`
- **Why non-trivial**: One sentence on the key mathematical insight

Example:
1. `cantorPairing_surjective`: Cantor pairing is surjective — proved — constructive inverse
2. `cantorPairing_injective`: Cantor pairing is injective — proved — diagonal argument
3. `cantorPairing_bijection`: Cantor pairing is a bijection — proved_with_lemma_sorry — follows from 1+2

### STEP 2: PROVE THEOREMS (completeness gate)

Every theorem declared as `proved` MUST have a complete, compiling Lean proof.
No `sorry` on the main result. If you cannot complete a proof, change its status
to `conjecture` or `proved_with_lemma_sorry` and explain why.

For `proved_with_lemma_sorry`:
- The theorem statement must be complete (no sorry in the statement)
- `sorry` is allowed ONLY in supporting lemmas, never the main proof
- A comment must explain what the sorry replaces and why it's deferred

For your BEST theorem, also provide:
- A generalization or strengthening (can use sorry if proving would take too long)
- A boundary case or counterexample showing where the result fails

### STEP 3: Anti-patterns (reject these)

These tactics indicate trivial proofs:
- `native_decide` / `decide` / `norm_num` / `rfl` — unless genuinely proving a numeric fact
- `simp only []` with no simp set specified
- `sorry` on any theorem declared as `proved`

`omega`, `linarith`, and `Aesop` are fine for supporting lemmas.
`sorry` is fine for conjectures and generalizations.

### STEP 4: Novelty

Your theorems must be genuinely new. If a statement appears in a textbook,
generalize it. If you cannot formalize a concept rigorously, pick a different topic.

### Output format

Your output must include:
1. `.lean` files with the proofs (structured as declared in Step 1)
2. `FUTURE_DIRECTIONS.md` with 3-5 research conjectures extending the work

Both are required. Missing FUTURE_DIRECTIONS.md = automatic quality penalty.


## Output format reminder

Your output must include `.lean` files AND a `FUTURE_DIRECTIONS.md` file.
The .lean files contain the proofs. The FUTURE_DIRECTIONS.md contains 3-5
research conjectures that extend the work. Both are required.
Be precise, be deep, be world-class.
