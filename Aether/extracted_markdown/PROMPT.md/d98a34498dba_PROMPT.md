
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

**Title**: `DescentSystem` abstraction from scratch (the catalog had n
**Domain**: Applications
**Mathematical framing**: # Future Directions: Descent Basin Theory

## Synthesis

This cycle built the `DescentSystem` abstraction from scratch (the catalog had no
prior basin/descent infrastructure, so this was a cold start) and proved the
**Basin Fixed Point Theorem**: for a finite state space equipped with a discrete
dynamics `step` and a `ℕ`-valued Lyapunov ("energy") function that strictly
decreases away from fixed points, the number of basins of attraction equals the
number of fixed points. The structural engine is a single induction
(`step_iterate_isFix`): the energy value bounds the worst-case length of a descent
path, so `step^[energy s] s` always lands on a fixed point. From this one lemma the
whole edifice follows — the limit map `limitPoint` is well defined, its range is
*exactly* the fixed-point set (`range_limitPoint_eq_fixedPoints`), its fibers are the
basins, and these basins partition the space (`iUnion_basin_eq_univ`,
`basin_disjoint`).

The cleanest structural insight is that **basins are literally the fibers of the
limit map**, so "counting basins" is a pure image/fiber computation rather than a
dynamical one. This made two extensions almost syntactic: basin counts are
*multiplicative* across independent subsystems (`prod_fixedPoint_count`), and they
are *equivariant* under any energy-preserving symmetry of the dynamics
(`limitPoint_equivariant`, `isFix_equiv`). The multiplicativity result is exactly
the classical (`q = 1`) shadow of the conjectured "quantum" deformation of basin
counting, and the equivariance result is exactly the group action one needs to feed
into a Burnside-style count of basins modulo symmetry.

What did *not* make it into this cycle: a real-valued (rather than `ℕ`-valued)
Lyapunov function, and the Burnside count itself. The `ℕ`-valued energy was a
deliberate simplification — it gives a concrete iteration bound `energy s` and
sidesteps well-foundedness subtleties. The boundary where the current proof breaks
is precisely the move to `ℝ`-valued energy with only a *strict* (not quantized)
decrease: there the bound "`energy s` steps suffice" fails, and one needs either a
discreteness/Łojasiewicz-type hypothesis or a well-founded-recursion argument. That
boundary is the seed for Directions 1 and 5 below.

## Results Summary

- `DescentSystem.step_iterate_isFix`: proved — the key descent lemma; `energy s`
  iterations always reach a fixed point, giving the well-definedness of the limit map.
- `DescentSystem.limitPoint_isFixedPt`: proved — every state flows to a fixed point.
- `DescentSystem.limitPoint_eq_self`: proved — fixed points are their own limit.
- `DescentSystem.range_limitPoint_eq_fixedPoints`: proved — the basin–fixed-point
  correspondence (image of the limit map = fixed-point set).
- `DescentSystem.basin_count_eq_fixedPoint_count`: proved — **the Basin Fixed Point
  Theorem** in cardinality form (#basins = #fixed points).
- `DescentSystem.mem_basin_self`, `basin_disjoint`, `iUnion_basin_eq_univ`: proved —
  the basins form a partition of the state space indexed by fixed points.
- `DescentSystem.prod`, `prod_isFix_iff`, `prod_fixedPoint_count`: proved —
  multiplicativity of basin counts across independent (product) subsystems.
- `DescentSystem.isFix_equiv`, `limitPoint_equivariant`: proved — symmetries of the
  dynamics permute fixed points and intertwine the basin map (equivariance of basins).

## Research Directions

### Direction 1: Discrete Morse inequalities from descent decomposition
**Hypothesis**: Extend `DescentSystem` to track critical cells of every index (not
only minima) on a finite CW/simplicial complex, and prove the weak Morse
inequality `b_k ≤ c_k` (the k-th Betti number is bounded by the number of critical
k-cells), together with the Euler identity `Σ (−1)^k c_k = χ`.
The key insight is that the orbit-injectivity / fiber structure of `limitPoint`
already gives the alternating-sum bookkeeping needed for the Euler characteristic;
each basin is a "descending cell" and the partition `iUnion_basin_eq_univ` is the
cell decomposition. **Test**: build a `DescentSystem` whose energy is a discrete
Morse function on a small complex (e.g. a triangulated circle/torus), define
`criticalCells k`, and prove `c_k ≥ b_k` against the catalog's
`Geometry.DiscreteMorseInequalities` (`homology_finrank_le`, `euler_char_eq`).
**Why now?** The Lyapunov/non-cycling machinery (`step_iterate_isFix`) makes
discrete gradient flow well defined, and `basin_count_eq_fixedPoint_count` is the
index-0 case of the inequality. **If true**: connects our geometry result to the
catalog's homological-algebra Morse file, a genuine cross-domain bridge.
**If false**: pinpoints which non-cycling hypothesis is too weak to control
higher-index cells.

### Direction 2: Equivariant basin counting via Burnside's lemma
**Hypothesis**: For a finite group `G` acting on `S` by energy-preserving symmetries
that commute with `step`, the number of basins modulo `G` equals
`(1/|G|) Σ_{g∈G} #{basins fixed by g}`, and a basin is fixed by `g` iff its limit
point is a `g`-symmetric critical point.
The key insight is that `limitPoint_equivariant` already shows `G` acts on the set
of basins (= fibers of `limitPoint`), so Burnside applies verbatim to that action.
**Test**: package the `G`-action as a `MulAction` on `Set.range D.limitPoint` and
invoke Mathlib's `MulAction.sum_card_fixedBy_eq_card_orbits` (verify exact name in
the project's Mathlib). **Why now?** `isFix_equiv` + `limitPoint_equivariant` give
the action and its compatibility with fixed points; only the orbit-counting wrapper
is missing. **If true**: yields a closed-form count of *essentially distinct*
minima found by symmetric descent (e.g. neural-net neuron-permutation symmetry).
**If false**: reveals that energy-invariance alone does not make the action
well defined on basins, isolating the missing hypothesis.

### Direction 3: Quantum deformation of basin counting (WDVV test)
**Hypothesis**: Define `Q(q) = Σ_paths q^{length}` over descent paths and a
`q`-deformed product on basins; then `prod_fixedPoint_count` is the `q→1` limit, and
the deformed product satisfies an associativity (WDVV) relation iff the basin
structure carries a quantum-cohomology ring.
The key insight is that multiplicativity of classical basin counts
(`prod_fixedPoint_count`) is precisely the classical limit of quantum
multiplicativity, so deforming the product is the natural next algebraic step.
**Test**: compute `Q(q)` symbolically for a handful of explicit small `DescentSystem`s
and check the WDVV relation by `decide`/`norm_num` on rationals. **Why now?** We now
have a rigorous, computable classical count to deform. **If true**: strong evidence
for the Gromov–Witten analogy motivating the whole program. **If false** (WDVV fails
generically): the strong GW conjecture is refuted, which is itself a clean negative
result.

### Direction 4: Real-valued / Łojasiewicz Lyapunov functions
**Hypothesis**: Replace `energy : S → ℕ` with `energy : S → ℝ` plus a *uniform* gap
`∃ δ > 0, step s ≠ s → energy s − energy (step s) ≥ δ`; then descent still reaches a
fixed point in at most `⌈(energy s − min energy)/δ⌉` steps and the Basin Fixed Point
Theorem survives unchanged.
The key insight is that the integer iteration bound used in `step_iterate_isFix`
generalizes to any *quantized* strict decrease, and a uniform gap is the minimal
hypothesis that restores quantization over `ℝ`. **Test**: re-prove
`step_iterate_isFix` with the `ℝ`+gap hypothesis using a `Nat.ceil` bound. **Why
now?** The current proof's only use of `ℕ` is the discreteness of the decrease; the
gap hypothesis isolates exactly that dependence. **If true**: bridges to continuous
optimization. **If false**: shows the discreteness is essential, not cosmetic.

### Direction 5: Continuous basin theory via Łojasiewicz gradient flow
**Hypothesis**: For a real-analytic loss on `ℝⁿ`, the Łojasiewicz inequality
`|∇L(θ)|² ≥ c |L(θ) − L(θ*)|^α` forces gradient-flow trajectories to have finite
length and converge, yielding a continuous basin map whose fibers partition a
neighborhood of the critical set — the continuous Basin Fixed Point Theorem.
The key insight is that the Łojasiewicz inequality is the continuous analogue of our
`strict_descent`/uniform-gap axiom: both forbid stalling at non-critical points, so
"bounded orbit length → Cauchy → convergence" mirrors our discrete
"iterate count bounded → fixed point". **Test**: state the Łojasiewicz–Simon
inequality in Mathlib's analysis API and prove finite trajectory length implies
convergence. **Why now?** Direction 4 produces the exact intermediate abstraction
(quantized-decrease descent) whose continuous limit this is. **If true**: extends
the theory to the setting of actual neural-network training. **If false**: identifies
which regularity (analyticity vs. smoothness) the convergence genuinely requires.

**Concept description**: # Future Directions: Descent Basin Theory

## Synthesis

This cycle built the `DescentSystem` abstraction from scratch (the catalog had no
prior basin/descent infrastructure, so this was a cold start) and proved the
**Basin Fixed Point Theorem**: for a finite state space equipped with a discrete
dynamics `step` and a `ℕ`-valued Lyapunov ("energy") function that strictly
decreases away from fixed points, the number of basins of attraction equals the
number of fixed points. The structural engine is a single induction
(`step_iterate_isFix`): the energy value bounds the worst-case length of a descent
path, so `step^[energy s] s` always lands on a fixed point. From this one lemma the
whole edifice follows — the limit map `limitPoint` is well defined, its range is
*exactly* the fixed-point set (`range_limitPoint_eq_fixedPoints`), its fibers are the
basins, and these basins partition the space (`iUnion_basin_eq_univ`,
`basin_disjoint`).

The cleanest structural insight is that **basins are literally the fibers of the
limit map**, so "counting basins" is a pure image/fiber computation rather than a
dynamical one. This made two extensions almost syntactic: basin counts are
*multiplicative* across independent subsystems (`prod_fixedPoint_count`), and they
are *equivariant* under any energy-preserving symmetry of the dynamics
(`limitPoint_equivariant`, `isFix_equiv`). The multiplicativity result is exactly
the classical (`q = 1`) shadow of the conjectured "quantum" deformation of basin
counting, and the equivariance result is exactly the group action one needs to feed
into a Burnside-style count of basins modulo symmetry.

What did *not* make it into this cycle: a real-valued (rather than `ℕ`-valued)
Lyapunov function, and the Burnside count itself. The `ℕ`-valued energy was a
deliberate simplification — it gives a concrete iteration bound `energy s` and
sidesteps well-foundedness subtleties. The boundary where the current proof breaks
is precisely the move to `ℝ`-valued energy with only a *strict* (not quantized)
decrease: there the bound "`energy s` steps suffice" fails, and one needs either a
discreteness/Łojasiewicz-type hypothesis or a well-founded-recursion argument. That
boundary is the seed for Directions 1 and 5 below.

## Results Summary

- `DescentSystem.step_iterate_isFix`: proved — the key descent lemma; `energy s`
  iterations always reach a fixed point, giving the well-definedness of the limit map.
- `DescentSystem.limitPoint_isFixedPt`: proved — every state flows to a fixed point.
- `DescentSystem.limitPoint_eq_self`: proved — fixed points are their own limit.
- `DescentSystem.range_limitPoint_eq_fixedPoints`: proved — the basin–fixed-point
  correspondence (image of the limit map = fixed-point set).
- `DescentSystem.basin_count_eq_fixedPoint_count`: proved — **the Basin Fixed Point
  Theorem** in cardinality form (#basins = #fixed points).
- `DescentSystem.mem_basin_self`, `basin_disjoint`, `iUnion_basin_eq_univ`: proved —
  the basins form a partition of the state space indexed by fixed points.
- `DescentSystem.prod`, `prod_isFix_iff`, `prod_fixedPoint_count`: proved —
  multiplicativity of basin counts across independent (product) subsystems.
- `DescentSystem.isFix_equiv`, `limitPoint_equivariant`: proved — symmetries of the
  dynamics permute fixed points and intertwine the basin map (equivariance of basins).

## Research Directions

### Direction 1: Discrete Morse inequalities from descent decomposition
**Hypothesis**: Extend `DescentSystem` to track critical cells of every index (not
only minima) on a finite CW/simplicial complex, and prove the weak Morse
inequality `b_k ≤ c_k` (the k-th Betti number is bounded by the number of critical
k-cells), together with the Euler identity `Σ (−1)^k c_k = χ`.
The key insight is that the orbit-injectivity / fiber structure of `limitPoint`
already gives the alternating-sum bookkeeping needed for the Euler characteristic;
each basin is a "descending cell" and the partition `iUnion_basin_eq_univ` is the
cell decomposition. **Test**: build a `DescentSystem` whose energy is a discrete
Morse function on a small complex (e.g. a triangulated circle/torus), define
`criticalCells k`, and prove `c_k ≥ b_k` against the catalog's
`Geometry.DiscreteMorseInequalities` (`homology_finrank_le`, `euler_char_eq`).
**Why now?** The Lyapunov/non-cycling machinery (`step_iterate_isFix`) makes
discrete gradient flow well defined, and `basin_count_eq_fixedPoint_count` is the
index-0 case of the inequality. **If true**: connects our geometry result to the
catalog's homological-algebra Morse file, a genuine cross-domain bridge.
**If false**: pinpoints which non-cycling hypothesis is too weak to control
higher-index cells.

### Direction 2: Equivariant basin counting via Burnside's lemma
**Hypothesis**: For a finite group `G` acting on `S` by energy-preserving symmetries
that commute with `step`, the number of basins modulo `G` equals
`(1/|G|) Σ_{g∈G} #{basins fixed by g}`, and a basin is fixed by `g` iff its limit
point is a `g`-symmetric critical point.
The key insight is that `limitPoint_equivariant` already shows `G` acts on the set
of basins (= fibers of `limitPoint`), so Burnside applies verbatim to that action.
**Test**: package the `G`-action as a `MulAction` on `Set.range D.limitPoint` and
invoke Mathlib's `MulAction.sum_card_fixedBy_eq_card_orbits` (verify exact name in
the project's Mathlib). **Why now?** `isFix_equiv` + `limitPoint_equivariant` give
the action and its compatibility with fixed points; only the orbit-counting wrapper
is missing. **If true**: yields a closed-form count of *essentially distinct*
minima found by symmetric descent (e.g. neural-net neuron-permutation symmetry).
**If false**: reveals that energy-invariance alone does not make the action
well defined on basins, isolating the missing hypothesis.

### Direction 3: Quantum deformation of basin counting (WDVV test)
**Hypothesis**: Define `Q(q) = Σ_paths q^{length}` over descent paths and a
`q`-deformed product on basins; then `prod_fixedPoint_count` is the `q→1` limit, and
the deformed product satisfies an associativity (WDVV) relation iff the basin
structure carries a quantum-cohomology ring.
The key insight is that multiplicativity of classical basin counts
(`prod_fixedPoint_count`) is precisely the classical limit of quantum
multiplicativity, so deforming the product is the natural next algebraic step.
**Test**: compute `Q(q)` symbolically for a handful of explicit small `DescentSystem`s
and check the WDVV relation by `decide`/`norm_num` on rationals. **Why now?** We now
have a rigorous, computable classical count to deform. **If true**: strong evidence
for the Gromov–Witten analogy motivating the whole program. **If false** (WDVV fails
generically): the strong GW conjecture is refuted, which is itself a clean negative
result.

### Direction 4: Real-valued / Łojasiewicz Lyapunov functions
**Hypothesis**: Replace `energy : S → ℕ` with `energy : S → ℝ` plus a *uniform* gap
`∃ δ > 0, step s ≠ s → energy s − energy (step s) ≥ δ`; then descent still reaches a
fixed point in at most `⌈(energy s − min energy)/δ⌉` steps and the Basin Fixed Point
Theorem survives unchanged.
The key insight is that the integer iteration bound used in `step_iterate_isFix`
generalizes to any *quantized* strict decrease, and a uniform gap is the minimal
hypothesis that restores quantization over `ℝ`. **Test**: re-prove
`step_iterate_isFix` with the `ℝ`+gap hypothesis using a `Nat.ceil` bound. **Why
now?** The current proof's only use of `ℕ` is the discreteness of the decrease; the
gap hypothesis isolates exactly that dependence. **If true**: bridges to continuous
optimization. **If false**: shows the discreteness is essential, not cosmetic.

### Direction 5: Continuous basin theory via Łojasiewicz gradient flow
**Hypothesis**: For a real-analytic loss on `ℝⁿ`, the Łojasiewicz inequality
`|∇L(θ)|² ≥ c |L(θ) − L(θ*)|^α` forces gradient-flow trajectories to have finite
length and converge, yielding a continuous basin map whose fibers partition a
neighborhood of the critical set — the continuous Basin Fixed Point Theorem.
The key insight is that the Łojasiewicz inequality is the continuous analogue of our
`strict_descent`/uniform-gap axiom: both forbid stalling at non-critical points, so
"bounded orbit length → Cauchy → convergence" mirrors our discrete
"iterate count bounded → fixed point". **Test**: state the Łojasiewicz–Simon
inequality in Mathlib's analysis API and prove finite trajectory length implies
convergence. **Why now?** Direction 4 produces the exact intermediate abstraction
(quantized-decrease descent) whose continuous limit this is. **If true**: extends
the theory to the setting of actual neural-network training. **If false**: identifies
which regularity (analyticity vs. smoothness) the convergence genuinely requires.

**Novelty estimate**: 0.75
**Breakthrough potential**: 0.75
Research domain: Applications
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
