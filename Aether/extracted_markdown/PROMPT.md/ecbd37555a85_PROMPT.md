
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

**Title**: The file `Geometry/StereographicCapacity.lean` establishes the metric backbone o
**Domain**: Novelty
**Mathematical framing**: # Future Directions: Stereographic Capacity Theory

The file `Geometry/StereographicCapacity.lean` establishes the metric backbone of
stereographic capacity theory: the exact chordal-distance formula

  ‖σ(x) − σ(y)‖² = 4‖x − y‖² / ((1 + ‖x‖²)(1 + ‖y‖²))

for inverse stereographic projection `σ`, together with its 2-Lipschitz upper
bound, its windowed bi-Lipschitz lower bound, and the two-way **packing transfer
theorems** that turn plane codes into spherical codes and back. These results
unify the catalog's `InverseStereo*` circle identities with the conformal-distortion
viewpoint of `HyperbolicPacking/Defs.lean`. The directions below are concrete,
falsifiable extensions that the next cycle can attack.

## 1. The dimension-free chordal formula

The circle (`ℝ → S¹`) and sphere (`ℝ² → S²`) cases are fully proved; the file
already records the general `n`-dimensional 2-Lipschitz statement
(`stereo_two_lipschitz_general`) under an abstract conformal hypothesis. The next
step is to discharge that hypothesis: define `σ : EuclideanSpace ℝ (Fin n) →
EuclideanSpace ℝ (Fin (n+1))` explicitly and prove
`dist (σ x) (σ y)² = 4 dist x y² / ((1+‖x‖²)(1+‖y‖²))` by reducing to the
coordinatewise sum-of-squares identity already used in dimensions 1 and 2.

**The key insight is** that the chordal formula is *purely algebraic* — it never
uses the dimension beyond expanding `‖·‖²` as a finite sum, so the `n = 1, 2`
`field_simp; ring` proofs are templates that lift through `Finset.sum`.
**Why now?** Mathlib's `EuclideanSpace` and `PiLp` norm-squared lemmas make the
sum manipulation routine, and the abstract `n`-dimensional shell is already in
place and compiling, so only the conformal identity remains.

## 2. A quantitative spherical-cap packing (Hamming-type) bound

Combine the packing transfer theorem with a volume/counting argument to bound the
number of points on `Sⁿ` whose pairwise chordal distance exceeds a threshold `ρ`.
Concretely: a chordal `ρ`-code pulls back (via `stereo_packing_pullback`) to a
`ρ/2`-separated plane code, whose cardinality inside `[−A,A]ⁿ` is bounded by a
volume ratio `(2A/(ρ/2) + 1)ⁿ`. Formalize this as
`(spherical code in a stereographic window).card ≤ (4A/ρ + 1)^n`.

**The key insight is** that separation lower bounds turn packing into a
*pigeonhole over a grid*: disjoint balls of radius `ρ/4` inside a box of side
`2A + ρ/2` can be counted by volume, no curvature integral required.
**Why now?** The pullback theorem already converts the spherical separation into a
clean Euclidean separation, and Mathlib has the box-counting / `Finset.card` and
measure-of-ball lemmas needed for the volume step.

## 3. Möbius-invariance of the capacity functional

Stereographic projection conjugates rigid rotations of `Sⁿ` to Möbius
transformations of `ℝⁿ ∪ {∞}`. Define the **stereographic capacity** of a finite
plane configuration as its minimum pairwise chordal distance, and prove it is
invariant under the subgroup of Möbius maps coming from sphere rotations, while
ordinary plane similarities only *rescale* it by a controlled factor.

**The key insight is** that the conformal weight `(1+‖x‖²)⁻¹` is exactly the
Jacobian density that makes chordal distance — not Euclidean distance — the
rotation-invariant metric; capacity must therefore be phrased in the chordal
metric to be a genuine sphere invariant.
**Why now?** The catalog's `InverseStereoMobiusNext.lean` already formalizes the
Möbius side of the dictionary, so this direction is a *bridge* connecting two
existing catalog modules through the new chordal formula.

## 4. Hyperbolic ↔ spherical capacity duality

The conformal factor here, `(1+‖x‖²)⁻¹`, is the formal `±` mirror of the Poincaré
factor `(1−‖x‖²)⁻¹` in `HyperbolicPacking/Defs.lean`. Prove a duality: a packing
bound in the spherical (positively curved) model maps, under `‖x‖ ↦ i‖x‖`
analytic continuation of the weight, to the hyperbolic `radialDistortion` bound,
giving a single curvature-parametrized inequality with `κ = +1, 0, −1` as special
cases.

**The key insight is** that all three constant-curvature packing distortions are
the *same rational function* `1/(1 − κ‖x‖²)` evaluated at `κ ∈ {−1,0,+1}`, so one
parametrized lemma subsumes the spherical theorem above and the hyperbolic
`radialDistortion` definition.
**Why now?** Both endpoint frameworks now exist in the catalog (spherical here,
hyperbolic in `HyperbolicPacking`), so the unifying `κ`-family is the immediate
synthesis target rather than new foundational work.

## 5. Sharpness: where the bi-Lipschitz lower bound degenerates

The windowed lower bound `chordSq_invStereo_ge` carries the factor `(1+A²)⁻²`,
which → 0 as the window `A → ∞`. Prove this degeneration is *unavoidable*:
exhibit sequences `sₖ, tₖ → ∞` with `|sₖ − tₖ| = 1` but `chordSq(σ sₖ, σ tₖ) → 0`,
establishing that no global (window-free) bi-Lipschitz lower bound exists, and
quantify the optimal exponent of `A`.

**The key insight is** that the point at infinity is a genuine metric singularity:
two unit-separated plane points become chordally indistinguishable near the north
pole, so the `(1+A²)⁻²` loss is the true rate, not an artifact of the proof.
**Why now?** The exact formula `chordSq_invStereo` makes the limit computation a
direct `Filter.Tendsto` calculation, turning a "sharpness" claim into a concrete
provable limit rather than a heuristic remark.

**Concept description**: # Future Directions: Stereographic Capacity Theory

The file `Geometry/StereographicCapacity.lean` establishes the metric backbone of
stereographic capacity theory: the exact chordal-distance formula

  ‖σ(x) − σ(y)‖² = 4‖x − y‖² / ((1 + ‖x‖²)(1 + ‖y‖²))

for inverse stereographic projection `σ`, together with its 2-Lipschitz upper
bound, its windowed bi-Lipschitz lower bound, and the two-way **packing transfer
theorems** that turn plane codes into spherical codes and back. These results
unify the catalog's `InverseStereo*` circle identities with the conformal-distortion
viewpoint of `HyperbolicPacking/Defs.lean`. The directions below are concrete,
falsifiable extensions that the next cycle can attack.

## 1. The dimension-free chordal formula

The circle (`ℝ → S¹`) and sphere (`ℝ² → S²`) cases are fully proved; the file
already records the general `n`-dimensional 2-Lipschitz statement
(`stereo_two_lipschitz_general`) under an abstract conformal hypothesis. The next
step is to discharge that hypothesis: define `σ : EuclideanSpace ℝ (Fin n) →
EuclideanSpace ℝ (Fin (n+1))` explicitly and prove
`dist (σ x) (σ y)² = 4 dist x y² / ((1+‖x‖²)(1+‖y‖²))` by reducing to the
coordinatewise sum-of-squares identity already used in dimensions 1 and 2.

**The key insight is** that the chordal formula is *purely algebraic* — it never
uses the dimension beyond expanding `‖·‖²` as a finite sum, so the `n = 1, 2`
`field_simp; ring` proofs are templates that lift through `Finset.sum`.
**Why now?** Mathlib's `EuclideanSpace` and `PiLp` norm-squared lemmas make the
sum manipulation routine, and the abstract `n`-dimensional shell is already in
place and compiling, so only the conformal identity remains.

## 2. A quantitative spherical-cap packing (Hamming-type) bound

Combine the packing transfer theorem with a volume/counting argument to bound the
number of points on `Sⁿ` whose pairwise chordal distance exceeds a threshold `ρ`.
Concretely: a chordal `ρ`-code pulls back (via `stereo_packing_pullback`) to a
`ρ/2`-separated plane code, whose cardinality inside `[−A,A]ⁿ` is bounded by a
volume ratio `(2A/(ρ/2) + 1)ⁿ`. Formalize this as
`(spherical code in a stereographic window).card ≤ (4A/ρ + 1)^n`.

**The key insight is** that separation lower bounds turn packing into a
*pigeonhole over a grid*: disjoint balls of radius `ρ/4` inside a box of side
`2A + ρ/2` can be counted by volume, no curvature integral required.
**Why now?** The pullback theorem already converts the spherical separation into a
clean Euclidean separation, and Mathlib has the box-counting / `Finset.card` and
measure-of-ball lemmas needed for the volume step.

## 3. Möbius-invariance of the capacity functional

Stereographic projection conjugates rigid rotations of `Sⁿ` to Möbius
transformations of `ℝⁿ ∪ {∞}`. Define the **stereographic capacity** of a finite
plane configuration as its minimum pairwise chordal distance, and prove it is
invariant under the subgroup of Möbius maps coming from sphere rotations, while
ordinary plane similarities only *rescale* it by a controlled factor.

**The key insight is** that the conformal weight `(1+‖x‖²)⁻¹` is exactly the
Jacobian density that makes chordal distance — not Euclidean distance — the
rotation-invariant metric; capacity must therefore be phrased in the chordal
metric to be a genuine sphere invariant.
**Why now?** The catalog's `InverseStereoMobiusNext.lean` already formalizes the
Möbius side of the dictionary, so this direction is a *bridge* connecting two
existing catalog modules through the new chordal formula.

## 4. Hyperbolic ↔ spherical capacity duality

The conformal factor here, `(1+‖x‖²)⁻¹`, is the formal `±` mirror of the Poincaré
factor `(1−‖x‖²)⁻¹` in `HyperbolicPacking/Defs.lean`. Prove a duality: a packing
bound in the spherical (positively curved) model maps, under `‖x‖ ↦ i‖x‖`
analytic continuation of the weight, to the hyperbolic `radialDistortion` bound,
giving a single curvature-parametrized inequality with `κ = +1, 0, −1` as special
cases.

**The key insight is** that all three constant-curvature packing distortions are
the *same rational function* `1/(1 − κ‖x‖²)` evaluated at `κ ∈ {−1,0,+1}`, so one
parametrized lemma subsumes the spherical theorem above and the hyperbolic
`radialDistortion` definition.
**Why now?** Both endpoint frameworks now exist in the catalog (spherical here,
hyperbolic in `HyperbolicPacking`), so the unifying `κ`-family is the immediate
synthesis target rather than new foundational work.

## 5. Sharpness: where the bi-Lipschitz lower bound degenerates

The windowed lower bound `chordSq_invStereo_ge` carries the factor `(1+A²)⁻²`,
which → 0 as the window `A → ∞`. Prove this degeneration is *unavoidable*:
exhibit sequences `sₖ, tₖ → ∞` with `|sₖ − tₖ| = 1` but `chordSq(σ sₖ, σ tₖ) → 0`,
establishing that no global (window-free) bi-Lipschitz lower bound exists, and
quantify the optimal exponent of `A`.

**The key insight is** that the point at infinity is a genuine metric singularity:
two unit-separated plane points become chordally indistinguishable near the north
pole, so the `(1+A²)⁻²` loss is the true rate, not an artifact of the proof.
**Why now?** The exact formula `chordSq_invStereo` makes the limit computation a
direct `Filter.Tendsto` calculation, turning a "sharpness" claim into a concrete
provable limit rather than a heuristic remark.

**Novelty estimate**: 0.75
**Breakthrough potential**: 0.75
Research domain: Novelty
Research mode: team




### Recent Discoveries in Catalog
No previous research cycles completed yet. This is a cold start — prioritize sorry_fill on the priority targets (CarmichaelComposite, Fib_gcd_identity) to close known open problems, or target cross-domain bridge theorems for novelty.


## v8 Depth Requirements -- Conceptual Unifier: Duality & Representation Research Engine

You are leading a mathematical research team. Your goal is to produce groundbreaking,
master-class, useful, novel, and marvelous new Mathematics that pushes the frontier of human knowledge.

This engine is configured for **Conceptual Unification (Duality & Representation)**. Search for deep dualities, representation theorems, and dual translations (such as Stone duality, Gelfand duality, or Fourier/Pontryagin dualities).

### RESEARCH CORE METHODOLOGY:
1. **Dual Translations**: Look for dual formulations of your mathematical objects. Translate geometric or topological spaces into algebraic representations (e.g. rings of functions), and algebraic structures back into geometric spaces.
2. **Representation Theorems**: Seek to represent abstract algebraic or topological structures as concrete operations on simpler, well-understood spaces (e.g. matrices, sets, or functions).
3. **Spectral Perspectives**: Leverage spectral properties, duality pairings, and transform methods to translate hard problems in the primary space into easier problems in the dual space.

### DELIVERABLES:
- **Lean 4 proofs** of deep, non-trivial theorems with complete proofs (no sorry on main results).
- **Lab Notebook** comment blocks in each .lean file detailing Hypothesis, Result, Insight, and Failure analysis.
- **FUTURE_DIRECTIONS.md** outlining the Synthesis of your findings, a Results Summary, and 3-5 bold, falsifiable research directions to steer the next cycle.


## Output format reminder

Your output must include `.lean` files AND a `FUTURE_DIRECTIONS.md` file.
The .lean files contain the proofs. The FUTURE_DIRECTIONS.md contains 3-5
research conjectures that extend the work. Both are required.
Be precise, be deep, be world-class.
