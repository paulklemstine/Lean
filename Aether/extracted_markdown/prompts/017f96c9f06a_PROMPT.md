
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

**Title**: This cycle moved the catalog's Dream Logic line of work from the *object level* 
**Domain**: Logic
**Mathematical framing**: # Future Directions — Dream Logic II: Structural Meta-Theory of Paraconsistent Consequence

## Synthesis

This cycle moved the catalog's Dream Logic line of work from the *object level* to the
*meta level*. The existing `Logic.DreamLogic.Paraconsistent` file had established how
Priest's Logic of Paradox (`LP`) behaves on individual formulas — contradictions do not
explode (`explosion_fails`), gluts are satisfiable (`contradiction_satisfiable`), excluded
middle and non-contradiction remain laws (`lem_valid`, `lnc_valid`), modus ponens fails
(`mp_fails`), and the minimal-glut relation `entailsMin` is non-monotone
(`retraction_nonmonotone`). What was missing was a clean account of *which structural
properties of a consequence relation survive paraconsistency*. The new file
`NonMonotone.lean` answers this: `LP`-consequence (`entails`) is a genuine Tarskian closure
operator — it satisfies reflexivity, monotonicity, and **Cut** — even though it rejects the
connective inferences of disjunctive syllogism and modus ponens.

The structural insight that emerged is a sharp dichotomy: **structural rules survive,
connective rules die.** The structural rules go through purely because `entails` quantifies
over models and "holding" is preserved under shrinking the premise set or substituting an
already-entailed formula. The connective failures (DS, MP), by contrast, are powered by a
single semantic fact — that a value `a` and its negation `LP.neg a` can be *simultaneously*
designated (the glut `bb`). The two value-level lemmas `LP.desig_conj` and
`LP.desig_disj_left` isolate exactly the monotonicity of designation under `min`/`max` that
makes adjunction and addition valid, while the *absence* of a disjointness law between a
value and its negation is what kills DS/MP. We also pinned down the precise sense in which
the non-monotone `LPm` is an *improvement* on `LP`: on a consistent premise set it recovers
the very modus-ponens conclusion `LP` discards (`entailsMin_recovers_mp`), i.e. classical
inference is recaptured exactly where no impossible object is forced.

What did not close: the deep half of Priest's characterization, that the `LP`-valid formulas
are *exactly* the classical tautologies. The easy direction (`LPvalid_imp_classicallyValid`)
is proved; the converse is recorded as the conjecture `lp_validity_eq_classical`. Its proof
needs a "squeeze" induction over formula structure using the two classical collapses of a
glut valuation, which is the natural next experiment.

## Results Summary

- `LP.desig_conj`: proved — designation is closed under conjunction (`min`), the engine of adjunction.
- `LP.desig_disj_left`: proved — designation is closed under disjunction (`max`), the engine of addition.
- `entails_refl`: proved — `LP`-consequence is reflexive.
- `entails_monotone`: proved — `LP`-consequence is monotone (the rule `LPm` deliberately breaks).
- `entails_cut`: proved — `LP`-consequence admits Cut, so it is a genuine Tarskian closure operator.
- `entails_and_intro`: proved — `LP` validates conjunction introduction (adjunction).
- `entails_or_intro_left`: proved — `LP` validates left disjunction introduction (addition).
- `disjunctive_syllogism_fails`: proved (disproof/counterexample) — the signature paraconsistent invalidity `{p, ¬p ∨ q} ⊭ q`.
- `entailsMin_recovers_mp`: proved — `LPm` recovers a modus-ponens conclusion that `LP` loses, so `LPm` is strictly stronger on consistent premises.
- `LPvalid_imp_classicallyValid`: proved — `LP`-validity implies classical validity (easy half of Priest's theorem).
- `lp_validity_eq_classical`: conjecture — the full equivalence "`LP`-valid ⟺ classically valid" (hard converse left as `sorry`).

## Research Directions

### Direction 1: Close Priest's validity characterization
**Hypothesis**: For every `Form` `A`, `LPvalid A ↔ ClassicallyValid A`; equivalently, the
converse `ClassicallyValid A → LPvalid A` holds.
**Test**: Prove by induction on `A` the "collapse" lemma: for any valuation `v`, define the
classical collapses `v⁺` (gluts `bb ↦ tt`) and `v⁻` (gluts `bb ↦ ff`); show
`eval v⁻ A ≤ eval v A ≤ eval v⁺ A` in the order `ff < bb < tt`, then deduce that if both
classical collapses designate `A` so does `v`. Refute by finding a classically valid `A`
with a glut valuation making `eval v A = ff`.
**Why now**: The forward direction and all the value-level designation lemmas
(`LP.desig_conj`, `LP.desig_disj_left`) are already in place; the order structure on `LP` is
exactly the `ff < bb < tt` chain these lemmas exploit, so the squeeze induction is a short
hop from existing machinery.
**If true**: Confirms that gluts add zero theorems while subtracting inferences — a precise
"conservativity over classical tautologies" statement, and a reusable bridge lemma for any
later `LP`/`LPm` completeness work.
**If false**: Would expose a divergence between this formalization's connectives and standard
`LP`, flagging a definitional bug in `eval`/`neg`/`conj`/`disj` worth fixing.

### Direction 2: Does Cut fail for the non-monotone `LPm`?
**Hypothesis**: `entailsMin` does **not** admit Cut: there exist `Γ, A, B` with
`entailsMin Γ A` and `entailsMin (insert A Γ) B` but `¬ entailsMin Γ B`.
**Test**: Search small premise sets over atoms `{0,1,2}` for a counterexample, using the
minimal-glut models computed by brute force over the finite valuation space restricted to the
occurring atoms; then formalize the witness. Conversely, attempt a Cut proof and locate the
exact step where minimality of models is not preserved under adding `A`.
**Why now**: `entails_cut` gives a clean template of what a working Cut proof looks like, and
`retraction_nonmonotone` already exhibits the non-monotone behaviour of `entailsMin` on a
two-atom set — the same machinery should produce a Cut counterexample.
**If true**: Pinpoints Cut as the structural rule that distinguishes monotone `LP` from
non-monotone `LPm`, completing the structural dichotomy started this cycle.
**If false** (Cut holds): `LPm` would be a surprisingly well-behaved non-monotone logic,
suggesting it is a closure operator despite non-monotonicity — a genuinely novel result.

### Direction 3: Bridge gluts to the pre-topological dream spaces
**Hypothesis**: The set of `LP`-valuations satisfying a fixed theory `Γ` carries a
`DreamSpace` structure (from `Logic.DreamLogic.DreamSpace`) whose "open" sets are exactly the
sets definable by single formulas, and this dream space is non-topological precisely when `Γ`
forces at least one glut.
**Test**: Define the map sending a formula `A` to its satisfying valuation set `{v | Holds v A}`,
show these sets satisfy the `DreamSpace` axioms (closure under finite intersection via
`entails_and_intro`), and exhibit a union of definable sets that is not definable iff a glut
is forced — mirroring `singletonDream_not_topological`.
**Why now**: `entails_and_intro` gives the finite-intersection closure for free, and
`DreamSpace.lean` already supplies the target structure and a non-topological separation
template; the two catalog files have never been connected.
**If true**: A genuine cross-domain bridge — paraconsistent semantics realized as
pre-topological geometry, with "contradiction" corresponding to "failure of the union axiom".
**If false**: Tells us definable sets are too rich (closed under union after all), redirecting
the bridge toward a coarser sub-collection of opens.

### Direction 4: Quantify the "recapture zone" of `LPm`
**Hypothesis**: For every premise set `Γ` with a glut-free (classical) model,
`entailsMin Γ A ↔ ClassicalConsequence Γ A` for all `A`; i.e. `LPm` collapses exactly to
classical logic on consistent theories.
**Test**: Define classical consequence over `Classical2` valuations, prove that any
glut-free model of `Γ` is minimal (its glut set `∅` cannot be properly shrunk), and conclude
both inclusions. The non-trivial inclusion `LPm ⊆ classical` needs that minimal models of a
consistent `Γ` are all glut-free.
**Why now**: `entailsMin_recovers_mp` is the first instance of exactly this collapse on a
concrete consistent set; generalizing the witness argument (every minimal model is glut-free)
is the obvious next step, and `classical_no_contradiction` already supplies the consistency
lemma for classical valuations.
**If true**: Establishes `LPm` as a conservative *non-monotone* extension of classical logic —
classical when you can be, paraconsistent only when forced — a precise formal statement of the
"dream logic" slogan.
**If false**: Reveals minimal models that carry unnecessary gluts even over consistent
theories, which would be a striking and instructive pathology of the minimality definition.

### Direction 5: A proof-theoretic (Hilbert/sequent) calculus matching `entails`
**Hypothesis**: There is a finite sound-and-complete sequent calculus for `entails`, and its
structural rules are exactly reflexivity + monotonicity (weakening) + Cut, with the
connective rules being adjunction, addition, double negation, LEM and LNC — but **no** DS/MP.
**Test**: Define a syntactic derivability relation `⊢` inductively from these rules and prove
soundness (`Γ ⊢ A → entails Γ A`) using this cycle's structural and connective theorems as the
rule-validity lemmas; then attempt completeness via a maximal-consistent-set construction.
**Why now**: This cycle already proved *every individual rule* of the proposed calculus
(`entails_refl`, `entails_monotone`, `entails_cut`, `entails_and_intro`,
`entails_or_intro_left`, plus the catalog's `lem_valid`/`lnc_valid`/`double_negation`), so
soundness is essentially assembling existing lemmas.
**If true**: Yields a fully verified proof system for dream logic, turning the semantic
results into a usable deductive apparatus.
**If false**: The failing rule identifies a semantic inference with no finite syntactic
counterpart — a concrete incompleteness phenomenon worth isolating.

**Concept description**: # Future Directions — Dream Logic II: Structural Meta-Theory of Paraconsistent Consequence

## Synthesis

This cycle moved the catalog's Dream Logic line of work from the *object level* to the
*meta level*. The existing `Logic.DreamLogic.Paraconsistent` file had established how
Priest's Logic of Paradox (`LP`) behaves on individual formulas — contradictions do not
explode (`explosion_fails`), gluts are satisfiable (`contradiction_satisfiable`), excluded
middle and non-contradiction remain laws (`lem_valid`, `lnc_valid`), modus ponens fails
(`mp_fails`), and the minimal-glut relation `entailsMin` is non-monotone
(`retraction_nonmonotone`). What was missing was a clean account of *which structural
properties of a consequence relation survive paraconsistency*. The new file
`NonMonotone.lean` answers this: `LP`-consequence (`entails`) is a genuine Tarskian closure
operator — it satisfies reflexivity, monotonicity, and **Cut** — even though it rejects the
connective inferences of disjunctive syllogism and modus ponens.

The structural insight that emerged is a sharp dichotomy: **structural rules survive,
connective rules die.** The structural rules go through purely because `entails` quantifies
over models and "holding" is preserved under shrinking the premise set or substituting an
already-entailed formula. The connective failures (DS, MP), by contrast, are powered by a
single semantic fact — that a value `a` and its negation `LP.neg a` can be *simultaneously*
designated (the glut `bb`). The two value-level lemmas `LP.desig_conj` and
`LP.desig_disj_left` isolate exactly the monotonicity of designation under `min`/`max` that
makes adjunction and addition valid, while the *absence* of a disjointness law between a
value and its negation is what kills DS/MP. We also pinned down the precise sense in which
the non-monotone `LPm` is an *improvement* on `LP`: on a consistent premise set it recovers
the very modus-ponens conclusion `LP` discards (`entailsMin_recovers_mp`), i.e. classical
inference is recaptured exactly where no impossible object is forced.

What did not close: the deep half of Priest's characterization, that the `LP`-valid formulas
are *exactly* the classical tautologies. The easy direction (`LPvalid_imp_classicallyValid`)
is proved; the converse is recorded as the conjecture `lp_validity_eq_classical`. Its proof
needs a "squeeze" induction over formula structure using the two classical collapses of a
glut valuation, which is the natural next experiment.

## Results Summary

- `LP.desig_conj`: proved — designation is closed under conjunction (`min`), the engine of adjunction.
- `LP.desig_disj_left`: proved — designation is closed under disjunction (`max`), the engine of addition.
- `entails_refl`: proved — `LP`-consequence is reflexive.
- `entails_monotone`: proved — `LP`-consequence is monotone (the rule `LPm` deliberately breaks).
- `entails_cut`: proved — `LP`-consequence admits Cut, so it is a genuine Tarskian closure operator.
- `entails_and_intro`: proved — `LP` validates conjunction introduction (adjunction).
- `entails_or_intro_left`: proved — `LP` validates left disjunction introduction (addition).
- `disjunctive_syllogism_fails`: proved (disproof/counterexample) — the signature paraconsistent invalidity `{p, ¬p ∨ q} ⊭ q`.
- `entailsMin_recovers_mp`: proved — `LPm` recovers a modus-ponens conclusion that `LP` loses, so `LPm` is strictly stronger on consistent premises.
- `LPvalid_imp_classicallyValid`: proved — `LP`-validity implies classical validity (easy half of Priest's theorem).
- `lp_validity_eq_classical`: conjecture — the full equivalence "`LP`-valid ⟺ classically valid" (hard converse left as `sorry`).

## Research Directions

### Direction 1: Close Priest's validity characterization
**Hypothesis**: For every `Form` `A`, `LPvalid A ↔ ClassicallyValid A`; equivalently, the
converse `ClassicallyValid A → LPvalid A` holds.
**Test**: Prove by induction on `A` the "collapse" lemma: for any valuation `v`, define the
classical collapses `v⁺` (gluts `bb ↦ tt`) and `v⁻` (gluts `bb ↦ ff`); show
`eval v⁻ A ≤ eval v A ≤ eval v⁺ A` in the order `ff < bb < tt`, then deduce that if both
classical collapses designate `A` so does `v`. Refute by finding a classically valid `A`
with a glut valuation making `eval v A = ff`.
**Why now**: The forward direction and all the value-level designation lemmas
(`LP.desig_conj`, `LP.desig_disj_left`) are already in place; the order structure on `LP` is
exactly the `ff < bb < tt` chain these lemmas exploit, so the squeeze induction is a short
hop from existing machinery.
**If true**: Confirms that gluts add zero theorems while subtracting inferences — a precise
"conservativity over classical tautologies" statement, and a reusable bridge lemma for any
later `LP`/`LPm` completeness work.
**If false**: Would expose a divergence between this formalization's connectives and standard
`LP`, flagging a definitional bug in `eval`/`neg`/`conj`/`disj` worth fixing.

### Direction 2: Does Cut fail for the non-monotone `LPm`?
**Hypothesis**: `entailsMin` does **not** admit Cut: there exist `Γ, A, B` with
`entailsMin Γ A` and `entailsMin (insert A Γ) B` but `¬ entailsMin Γ B`.
**Test**: Search small premise sets over atoms `{0,1,2}` for a counterexample, using the
minimal-glut models computed by brute force over the finite valuation space restricted to the
occurring atoms; then formalize the witness. Conversely, attempt a Cut proof and locate the
exact step where minimality of models is not preserved under adding `A`.
**Why now**: `entails_cut` gives a clean template of what a working Cut proof looks like, and
`retraction_nonmonotone` already exhibits the non-monotone behaviour of `entailsMin` on a
two-atom set — the same machinery should produce a Cut counterexample.
**If true**: Pinpoints Cut as the structural rule that distinguishes monotone `LP` from
non-monotone `LPm`, completing the structural dichotomy started this cycle.
**If false** (Cut holds): `LPm` would be a surprisingly well-behaved non-monotone logic,
suggesting it is a closure operator despite non-monotonicity — a genuinely novel result.

### Direction 3: Bridge gluts to the pre-topological dream spaces
**Hypothesis**: The set of `LP`-valuations satisfying a fixed theory `Γ` carries a
`DreamSpace` structure (from `Logic.DreamLogic.DreamSpace`) whose "open" sets are exactly the
sets definable by single formulas, and this dream space is non-topological precisely when `Γ`
forces at least one glut.
**Test**: Define the map sending a formula `A` to its satisfying valuation set `{v | Holds v A}`,
show these sets satisfy the `DreamSpace` axioms (closure under finite intersection via
`entails_and_intro`), and exhibit a union of definable sets that is not definable iff a glut
is forced — mirroring `singletonDream_not_topological`.
**Why now**: `entails_and_intro` gives the finite-intersection closure for free, and
`DreamSpace.lean` already supplies the target structure and a non-topological separation
template; the two catalog files have never been connected.
**If true**: A genuine cross-domain bridge — paraconsistent semantics realized as
pre-topological geometry, with "contradiction" corresponding to "failure of the union axiom".
**If false**: Tells us definable sets are too rich (closed under union after all), redirecting
the bridge toward a coarser sub-collection of opens.

### Direction 4: Quantify the "recapture zone" of `LPm`
**Hypothesis**: For every premise set `Γ` with a glut-free (classical) model,
`entailsMin Γ A ↔ ClassicalConsequence Γ A` for all `A`; i.e. `LPm` collapses exactly to
classical logic on consistent theories.
**Test**: Define classical consequence over `Classical2` valuations, prove that any
glut-free model of `Γ` is minimal (its glut set `∅` cannot be properly shrunk), and conclude
both inclusions. The non-trivial inclusion `LPm ⊆ classical` needs that minimal models of a
consistent `Γ` are all glut-free.
**Why now**: `entailsMin_recovers_mp` is the first instance of exactly this collapse on a
concrete consistent set; generalizing the witness argument (every minimal model is glut-free)
is the obvious next step, and `classical_no_contradiction` already supplies the consistency
lemma for classical valuations.
**If true**: Establishes `LPm` as a conservative *non-monotone* extension of classical logic —
classical when you can be, paraconsistent only when forced — a precise formal statement of the
"dream logic" slogan.
**If false**: Reveals minimal models that carry unnecessary gluts even over consistent
theories, which would be a striking and instructive pathology of the minimality definition.

### Direction 5: A proof-theoretic (Hilbert/sequent) calculus matching `entails`
**Hypothesis**: There is a finite sound-and-complete sequent calculus for `entails`, and its
structural rules are exactly reflexivity + monotonicity (weakening) + Cut, with the
connective rules being adjunction, addition, double negation, LEM and LNC — but **no** DS/MP.
**Test**: Define a syntactic derivability relation `⊢` inductively from these rules and prove
soundness (`Γ ⊢ A → entails Γ A`) using this cycle's structural and connective theorems as the
rule-validity lemmas; then attempt completeness via a maximal-consistent-set construction.
**Why now**: This cycle already proved *every individual rule* of the proposed calculus
(`entails_refl`, `entails_monotone`, `entails_cut`, `entails_and_intro`,
`entails_or_intro_left`, plus the catalog's `lem_valid`/`lnc_valid`/`double_negation`), so
soundness is essentially assembling existing lemmas.
**If true**: Yields a fully verified proof system for dream logic, turning the semantic
results into a usable deductive apparatus.
**If false**: The failing rule identifies a semantic inference with no finite syntactic
counterpart — a concrete incompleteness phenomenon worth isolating.

**Novelty estimate**: 0.75
**Breakthrough potential**: 0.75
Research domain: Logic
Research mode: team




### Recent Discoveries in Catalog
No previous research cycles completed yet. This is a cold start — prioritize sorry_fill on the priority targets (CarmichaelComposite, Fib_gcd_identity) to close known open problems, or target cross-domain bridge theorems for novelty.


## v12 Depth Requirements -- Speculative Specifier Research Engine

You are leading a mathematical research team. Your goal is to produce groundbreaking,
master-class, useful, novel, and marvelous new Mathematics that pushes the frontier of human knowledge.

This engine is configured for **Speculative Specifying (Bold Conjectures)**. Target high-risk, high-reward, grand-challenge level research.

### RESEARCH CORE METHODOLOGY:
1. **Grand Challenges**: Formulate bold, surprising, and non-trivial conjectures that challenge existing intuition. Even if a complete proof cannot be achieved in this cycle, outline precise strategies, obstacles, and partial results.
2. **Deep Speculation**: Explore radical connections that seem distant or impossible at first glance. Frame your theorems as seeds for entirely new fields of study.
3. **Long-Term Roadmap**: Dedicate significant intellectual effort to detailing the proof strategies and testable predictions in your future directions, laying out a clear path for future researchers.

### DELIVERABLES:
- **Lean 4 proofs** of deep, non-trivial theorems with complete proofs (no sorry on main results).
- **Lab Notebook** comment blocks in each .lean file detailing Hypothesis, Result, Insight, and Failure analysis.
- **FUTURE_DIRECTIONS.md** outlining the Synthesis of your findings, a Results Summary, and 3-5 bold, falsifiable research directions to steer the next cycle.


## Output format reminder

Your output must include `.lean` files AND a `FUTURE_DIRECTIONS.md` file.
The .lean files contain the proofs. The FUTURE_DIRECTIONS.md contains 3-5
research conjectures that extend the work. Both are required.
Be precise, be deep, be world-class.
