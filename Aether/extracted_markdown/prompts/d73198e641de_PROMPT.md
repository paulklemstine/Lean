
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

**Title**: The file `Catalog/Geometry/IsingStereoRG.lean` establishes the first rigorous, m
**Domain**: Geometry
**Mathematical framing**: # Future Directions: Inverse Stereographic Renormalization Group

The file `Catalog/Geometry/IsingStereoRG.lean` establishes the first rigorous, machine-checked
bridge between renormalization-group (RG) flow and stereographic/conformal geometry, in the
exactly solvable 1D Ising model. It proves that Kadanoff decimation is the quadratic map
`x ↦ x²` in the variable `x = tanh K`, that its eigenvalue at the ordered fixed point is exactly
the rescaling factor `2` (hence `ν = 1`), and that the second stereographic coordinate is the
Cayley transform of the decimation map. These results extend the Möbius/pole-map theory in
`Catalog/Geometry/StereographicRG.lean` (`moebiusF'`, `deriv_moebiusF'_formula`,
`conformal_factor_le_two`) and the projection identities in
`Catalog/Geometry/InverseStereoResearch.lean` (`inv_stereo_on_circle`, `inv_stereo_injective`).
Below are concrete, falsifiable directions that the next cycle should attack.

## 1. Conjugacy of decimation to angle-doubling on the projected circle

The decimation map `x ↦ x²` becomes, on the projected circle, a genuine conformal map. We
conjecture there is an explicit smooth conjugacy `h` with `h ∘ isingRG = D ∘ h`, where `D` is a
fixed Möbius/rotation-type map of `S¹` drawn from the `moebiusF'` family of `StereographicRG.lean`,
so that decimation is *linearized* on the circle. **The key insight is** that squaring in the
half-tangent variable is exactly angle-related on the circle, so the RG semigroup `rgIter` should
be conjugate to iterated composition of a single `moebiusF'` map with fixed poles. **Why now?**
Both halves now exist and are formalized in the same library — the Ising recursion here and the
two-pole Möbius calculus in `StereographicRG.lean` — so the conjugacy is a finite algebraic
identity well within reach of the existing `grind`/`field_simp` machinery.

## 2. Universality: every quadratic decimation gives `ν = 1` via `logb` of the multiplier

We proved `ising_correlation_length_exponent : Real.logb 2 (deriv isingRG 1) = 1`. Conjecture: for
*any* rescaling factor `b ≥ 2`, the corresponding decimation map (`x ↦ x^b`) has ordered-fixed-point
multiplier `b`, hence `Real.logb b (deriv (fun x => x^b) 1) = 1` and `ν = 1` independent of `b`.
**The key insight is** that `deriv (x^b) 1 = b` exactly, so the thermal exponent `log_b(b) = 1` is a
`logb_self_eq_one` tautology, proving block-size independence of the 1D exponent rigorously.
**Why now?** The `deriv_isingRG`/`Real.logb_self_eq_one` proof pattern generalizes verbatim, so a
single parametric theorem `correlation_length_exponent_universal (b : ℕ) (hb : 2 ≤ b)` is a small
extension that turns a one-off computation into a universality statement.

## 3. The beta-function/projection-derivative identity beyond the fixed point

`eigenvalue_eq_one_add_beta_deriv` proves the RG multiplier equals `1 + β'(x)` everywhere, not just
at fixed points. Conjecture: the *conformal factor* of the projected flow, `conformalFactor`, is the
geometric carrier of `β` — specifically that `deriv (fun x => (invStereo (isingRG x)).2) x` factors
through `conformalFactor (isingRG x)` times `β'`-data, giving a coordinate-free "beta equals
projection derivative" statement. **The key insight is** that the Cayley identity
`stereo_snd_eq_cayley_isingRG` turns RG flow into motion on `S¹`, where the only scale is the
conformal factor, so `β` must reappear as a circle-velocity. **Why now?** `deriv_stereo_fst_at_zero`
shows the conformal factor is already computable as a derivative in Lean; chaining it with
`deriv_betaIsing` via the chain rule is the natural next composition.

## 4. Möbius cocycle for multi-step decimation matches `rgUpdate_composition`

Iterating decimation `n` times sends `x ↦ x^(2^n)`. Conjecture: under the Cayley/stereographic
change of variables this `n`-step flow equals a *composition* of `moebiusF'` maps obeying the
transitivity law `rgUpdate_composition` already proven in `StereographicRG.lean`, so the RG
semigroup embeds as a sub-semigroup of the two-pole Möbius group with a closed-form cocycle for the
accumulated conformal factor `∏ conformalFactor`. **The key insight is** that decimation eigenvalues
multiply (`2^n`) exactly as Möbius multipliers compose, matching `rgUpdate_det = (1+a²)(1+b²)`.
**Why now?** `rgIter` and `rgUpdate_composition` are formalized and `rgIter_zero/one` give the base
cases, so an induction on `n` connecting `isingRG^[n]` to iterated `moebiusF'` is structurally ready.

## 5. Failure boundary: the bridge breaks for `x < 0` and complex couplings

The Cayley identity and circle membership hold for all real `x`, but the *physical* coupling region
is `x ∈ [0,1]`. Conjecture (falsifiable boundary case): for `x < 0` the decimation orbit still lands
on `S¹` (so `invStereo_on_circle` is robust) yet the monotone RG-flow interpretation fails because
`betaIsing` changes sign at `x = 1/2` (the zero of `deriv_betaIsing`), marking the crossover between
the two basins. **The key insight is** that `deriv betaIsing x = 2x − 1` vanishes exactly at the
midpoint `x = 1/2`, which is the geometric watershed between the disordered and ordered basins.
**Why now?** `deriv_betaIsing` is already proven, so locating and characterizing the `x = 1/2`
watershed — and showing the projected picture survives where the flow interpretation does not — is an
immediate, sharply testable corollary that delimits exactly where the conformal/RG dictionary holds.

**Concept description**: # Future Directions: Inverse Stereographic Renormalization Group

The file `Catalog/Geometry/IsingStereoRG.lean` establishes the first rigorous, machine-checked
bridge between renormalization-group (RG) flow and stereographic/conformal geometry, in the
exactly solvable 1D Ising model. It proves that Kadanoff decimation is the quadratic map
`x ↦ x²` in the variable `x = tanh K`, that its eigenvalue at the ordered fixed point is exactly
the rescaling factor `2` (hence `ν = 1`), and that the second stereographic coordinate is the
Cayley transform of the decimation map. These results extend the Möbius/pole-map theory in
`Catalog/Geometry/StereographicRG.lean` (`moebiusF'`, `deriv_moebiusF'_formula`,
`conformal_factor_le_two`) and the projection identities in
`Catalog/Geometry/InverseStereoResearch.lean` (`inv_stereo_on_circle`, `inv_stereo_injective`).
Below are concrete, falsifiable directions that the next cycle should attack.

## 1. Conjugacy of decimation to angle-doubling on the projected circle

The decimation map `x ↦ x²` becomes, on the projected circle, a genuine conformal map. We
conjecture there is an explicit smooth conjugacy `h` with `h ∘ isingRG = D ∘ h`, where `D` is a
fixed Möbius/rotation-type map of `S¹` drawn from the `moebiusF'` family of `StereographicRG.lean`,
so that decimation is *linearized* on the circle. **The key insight is** that squaring in the
half-tangent variable is exactly angle-related on the circle, so the RG semigroup `rgIter` should
be conjugate to iterated composition of a single `moebiusF'` map with fixed poles. **Why now?**
Both halves now exist and are formalized in the same library — the Ising recursion here and the
two-pole Möbius calculus in `StereographicRG.lean` — so the conjugacy is a finite algebraic
identity well within reach of the existing `grind`/`field_simp` machinery.

## 2. Universality: every quadratic decimation gives `ν = 1` via `logb` of the multiplier

We proved `ising_correlation_length_exponent : Real.logb 2 (deriv isingRG 1) = 1`. Conjecture: for
*any* rescaling factor `b ≥ 2`, the corresponding decimation map (`x ↦ x^b`) has ordered-fixed-point
multiplier `b`, hence `Real.logb b (deriv (fun x => x^b) 1) = 1` and `ν = 1` independent of `b`.
**The key insight is** that `deriv (x^b) 1 = b` exactly, so the thermal exponent `log_b(b) = 1` is a
`logb_self_eq_one` tautology, proving block-size independence of the 1D exponent rigorously.
**Why now?** The `deriv_isingRG`/`Real.logb_self_eq_one` proof pattern generalizes verbatim, so a
single parametric theorem `correlation_length_exponent_universal (b : ℕ) (hb : 2 ≤ b)` is a small
extension that turns a one-off computation into a universality statement.

## 3. The beta-function/projection-derivative identity beyond the fixed point

`eigenvalue_eq_one_add_beta_deriv` proves the RG multiplier equals `1 + β'(x)` everywhere, not just
at fixed points. Conjecture: the *conformal factor* of the projected flow, `conformalFactor`, is the
geometric carrier of `β` — specifically that `deriv (fun x => (invStereo (isingRG x)).2) x` factors
through `conformalFactor (isingRG x)` times `β'`-data, giving a coordinate-free "beta equals
projection derivative" statement. **The key insight is** that the Cayley identity
`stereo_snd_eq_cayley_isingRG` turns RG flow into motion on `S¹`, where the only scale is the
conformal factor, so `β` must reappear as a circle-velocity. **Why now?** `deriv_stereo_fst_at_zero`
shows the conformal factor is already computable as a derivative in Lean; chaining it with
`deriv_betaIsing` via the chain rule is the natural next composition.

## 4. Möbius cocycle for multi-step decimation matches `rgUpdate_composition`

Iterating decimation `n` times sends `x ↦ x^(2^n)`. Conjecture: under the Cayley/stereographic
change of variables this `n`-step flow equals a *composition* of `moebiusF'` maps obeying the
transitivity law `rgUpdate_composition` already proven in `StereographicRG.lean`, so the RG
semigroup embeds as a sub-semigroup of the two-pole Möbius group with a closed-form cocycle for the
accumulated conformal factor `∏ conformalFactor`. **The key insight is** that decimation eigenvalues
multiply (`2^n`) exactly as Möbius multipliers compose, matching `rgUpdate_det = (1+a²)(1+b²)`.
**Why now?** `rgIter` and `rgUpdate_composition` are formalized and `rgIter_zero/one` give the base
cases, so an induction on `n` connecting `isingRG^[n]` to iterated `moebiusF'` is structurally ready.

## 5. Failure boundary: the bridge breaks for `x < 0` and complex couplings

The Cayley identity and circle membership hold for all real `x`, but the *physical* coupling region
is `x ∈ [0,1]`. Conjecture (falsifiable boundary case): for `x < 0` the decimation orbit still lands
on `S¹` (so `invStereo_on_circle` is robust) yet the monotone RG-flow interpretation fails because
`betaIsing` changes sign at `x = 1/2` (the zero of `deriv_betaIsing`), marking the crossover between
the two basins. **The key insight is** that `deriv betaIsing x = 2x − 1` vanishes exactly at the
midpoint `x = 1/2`, which is the geometric watershed between the disordered and ordered basins.
**Why now?** `deriv_betaIsing` is already proven, so locating and characterizing the `x = 1/2`
watershed — and showing the projected picture survives where the flow interpretation does not — is an
immediate, sharply testable corollary that delimits exactly where the conformal/RG dictionary holds.

**Novelty estimate**: 0.75
**Breakthrough potential**: 0.75
Research domain: Geometry
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
