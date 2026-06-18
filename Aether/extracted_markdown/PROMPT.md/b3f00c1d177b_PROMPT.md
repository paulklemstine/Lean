
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

**Title**: The file `Geometry/FractalDimension.lean` builds the **set-local** theory of Hau
**Domain**: Bridges
**Mathematical framing**: # Future Directions: Set-Local Distortion of Hausdorff Dimension

The file `Geometry/FractalDimension.lean` builds the **set-local** theory of Hausdorff
dimension distortion: the `AntilipschitzOnWith` predicate, the lower bound
`AntilipschitzOnWith.le_dimH_image`, the set-local bi-Lipschitz invariance
`dimH_image_eq_of_lipschitzOn_antilipschitzOn`, and the two-sided Hölder squeeze
`dimH_image_bounds_of_holderOn_holderOn_inverse`. Mathlib previously only had the
*global* versions (`AntilipschitzWith.le_dimH_image`, `Isometry.dimH_image`). The
following directions extend this frontier.

## 1. Quasi-symmetric distortion governed by the modulus η

A natural next theorem replaces the single Hölder exponent by a scale-dependent
modulus η, asking how `dimH (f '' s)` depends on the asymptotics of η near `0` and `∞`.
Note carefully: the naïve guess `dimH (f '' s) ≤ dimH s` is **false** — quasi-symmetric
maps genuinely change dimension (this is exactly why conformal dimension is interesting).
The key insight is that an η-quasi-symmetric map is, *at each fixed scale*, bi-Hölder with
exponents determined by `log η(t)/log t`, so our `dimH_image_bounds_of_holderOn_holderOn_inverse`
applied on a countable scale decomposition should yield a bound of the form
`dimH (f '' s) ≤ (limsup_{t→0} log η(t)/log t) · dimH s`. Why now? The two-sided Hölder
squeeze is already proved on arbitrary subsets, and `dimH_bUnion` lets us glue countable
scale pieces, so the only missing ingredient is the per-scale bi-Hölder extraction from η.

## 2. Conformal dimension as a quasi-symmetric invariant

Define `cdim(X) = inf { dimH Y : Y quasi-symmetrically equivalent to X }`. The first
checkable theorem is that `cdim` is invariant under quasi-symmetric homeomorphisms and
that `cdim(X) ≤ dimH(X)` always. The key insight is that our
`dimH_image_eq_of_lipschitzOn_antilipschitzOn` is precisely the bi-Lipschitz special case
(modulus η linear), so `cdim` is exactly what survives after quotienting the bi-Lipschitz
invariance by the larger quasi-symmetric equivalence relation. Why now? The set-local
invariance theorem already certifies bi-Lipschitz invariance on arbitrary subsets; building
the equivalence relation and taking the infimum is a direct formal step on top of it.

## 3. IFS attractor dimension via the coding map's Hölder section

For an iterated function system of contractions with ratios `r₁,…,rₙ`, the coding map
`π : {1,…,n}^ℕ → K` onto the attractor is Hölder, and under the open set condition it admits
an antilipschitz section on a large subset. Applying
`dimH_image_bounds_of_holderOn_holderOn_inverse` to π then squeezes `dimH K` between
multiples of the symbolic-space dimension, recovering `dimH K = s` where `Σ rᵢˢ = 1`. The
key insight is that the open set condition is exactly the hypothesis that upgrades π from
merely Hölder to having a Hölder/antilipschitz inverse on a full-measure piece, which is the
input our two-sided bound consumes. Why now? The two-sided Hölder squeeze is set-local, so it
applies directly to the "good" subset furnished by the open set condition without needing π to
be globally invertible.

## 4. Product sets: the lower inequality via Lipschitz projections

The classical bound `dimH (A × B) ≥ dimH A + dimH B` should follow from slicing: fix `b ∈ B`,
note the inclusion `A ↪ A × B`, `a ↦ (a,b)` is an isometric (hence antilipschitz) embedding, and
combine with a fibered covering argument. The key insight is that
`AntilipschitzOnWith.le_dimH_image` gives `dimH A ≤ dimH (A × {b})` for free on each slice, so
the remaining work is purely the additive covering estimate connecting slice dimensions to the
product dimension. Why now? The set-local antilipschitz lower bound removes the need for a global
inverse of the slice inclusion, which is the technical obstruction in the standard proof.

## 5. Bi-Lipschitz embedding dimension lower bound `bldim(X) ≥ ⌈dimH X⌉`

Define `bldim(X)` as the least `n` such that `X` bi-Lipschitz embeds into `ℝⁿ`. Because a
bi-Lipschitz embedding restricted to `X` is simultaneously Lipschitz and antilipschitz on its
domain, our `dimH_image_eq_of_lipschitzOn_antilipschitzOn` shows such an embedding preserves
`dimH` exactly, and since `dimH (ℝⁿ) = n` this forces `dimH X ≤ n`, i.e. `bldim(X) ≥ ⌈dimH X⌉`.
The key insight is that the lower bound needs only set-local bi-Lipschitz invariance — no global
inverse on all of `ℝⁿ` — which is exactly what we proved. Why now? The invariance theorem gives
the lower bound immediately; the matching upper bound (Assouad-type embedding for doubling spaces)
becomes the sole remaining target.

**Concept description**: # Future Directions: Set-Local Distortion of Hausdorff Dimension

The file `Geometry/FractalDimension.lean` builds the **set-local** theory of Hausdorff
dimension distortion: the `AntilipschitzOnWith` predicate, the lower bound
`AntilipschitzOnWith.le_dimH_image`, the set-local bi-Lipschitz invariance
`dimH_image_eq_of_lipschitzOn_antilipschitzOn`, and the two-sided Hölder squeeze
`dimH_image_bounds_of_holderOn_holderOn_inverse`. Mathlib previously only had the
*global* versions (`AntilipschitzWith.le_dimH_image`, `Isometry.dimH_image`). The
following directions extend this frontier.

## 1. Quasi-symmetric distortion governed by the modulus η

A natural next theorem replaces the single Hölder exponent by a scale-dependent
modulus η, asking how `dimH (f '' s)` depends on the asymptotics of η near `0` and `∞`.
Note carefully: the naïve guess `dimH (f '' s) ≤ dimH s` is **false** — quasi-symmetric
maps genuinely change dimension (this is exactly why conformal dimension is interesting).
The key insight is that an η-quasi-symmetric map is, *at each fixed scale*, bi-Hölder with
exponents determined by `log η(t)/log t`, so our `dimH_image_bounds_of_holderOn_holderOn_inverse`
applied on a countable scale decomposition should yield a bound of the form
`dimH (f '' s) ≤ (limsup_{t→0} log η(t)/log t) · dimH s`. Why now? The two-sided Hölder
squeeze is already proved on arbitrary subsets, and `dimH_bUnion` lets us glue countable
scale pieces, so the only missing ingredient is the per-scale bi-Hölder extraction from η.

## 2. Conformal dimension as a quasi-symmetric invariant

Define `cdim(X) = inf { dimH Y : Y quasi-symmetrically equivalent to X }`. The first
checkable theorem is that `cdim` is invariant under quasi-symmetric homeomorphisms and
that `cdim(X) ≤ dimH(X)` always. The key insight is that our
`dimH_image_eq_of_lipschitzOn_antilipschitzOn` is precisely the bi-Lipschitz special case
(modulus η linear), so `cdim` is exactly what survives after quotienting the bi-Lipschitz
invariance by the larger quasi-symmetric equivalence relation. Why now? The set-local
invariance theorem already certifies bi-Lipschitz invariance on arbitrary subsets; building
the equivalence relation and taking the infimum is a direct formal step on top of it.

## 3. IFS attractor dimension via the coding map's Hölder section

For an iterated function system of contractions with ratios `r₁,…,rₙ`, the coding map
`π : {1,…,n}^ℕ → K` onto the attractor is Hölder, and under the open set condition it admits
an antilipschitz section on a large subset. Applying
`dimH_image_bounds_of_holderOn_holderOn_inverse` to π then squeezes `dimH K` between
multiples of the symbolic-space dimension, recovering `dimH K = s` where `Σ rᵢˢ = 1`. The
key insight is that the open set condition is exactly the hypothesis that upgrades π from
merely Hölder to having a Hölder/antilipschitz inverse on a full-measure piece, which is the
input our two-sided bound consumes. Why now? The two-sided Hölder squeeze is set-local, so it
applies directly to the "good" subset furnished by the open set condition without needing π to
be globally invertible.

## 4. Product sets: the lower inequality via Lipschitz projections

The classical bound `dimH (A × B) ≥ dimH A + dimH B` should follow from slicing: fix `b ∈ B`,
note the inclusion `A ↪ A × B`, `a ↦ (a,b)` is an isometric (hence antilipschitz) embedding, and
combine with a fibered covering argument. The key insight is that
`AntilipschitzOnWith.le_dimH_image` gives `dimH A ≤ dimH (A × {b})` for free on each slice, so
the remaining work is purely the additive covering estimate connecting slice dimensions to the
product dimension. Why now? The set-local antilipschitz lower bound removes the need for a global
inverse of the slice inclusion, which is the technical obstruction in the standard proof.

## 5. Bi-Lipschitz embedding dimension lower bound `bldim(X) ≥ ⌈dimH X⌉`

Define `bldim(X)` as the least `n` such that `X` bi-Lipschitz embeds into `ℝⁿ`. Because a
bi-Lipschitz embedding restricted to `X` is simultaneously Lipschitz and antilipschitz on its
domain, our `dimH_image_eq_of_lipschitzOn_antilipschitzOn` shows such an embedding preserves
`dimH` exactly, and since `dimH (ℝⁿ) = n` this forces `dimH X ≤ n`, i.e. `bldim(X) ≥ ⌈dimH X⌉`.
The key insight is that the lower bound needs only set-local bi-Lipschitz invariance — no global
inverse on all of `ℝⁿ` — which is exactly what we proved. Why now? The invariance theorem gives
the lower bound immediately; the matching upper bound (Assouad-type embedding for doubling spaces)
becomes the sole remaining target.

**Novelty estimate**: 0.75
**Breakthrough potential**: 0.75
Research domain: Bridges
Research mode: team




### Recent Discoveries in Catalog
No previous research cycles completed yet. This is a cold start — prioritize sorry_fill on the priority targets (CarmichaelComposite, Fib_gcd_identity) to close known open problems, or target cross-domain bridge theorems for novelty.


## v9 Depth Requirements -- Adversarial Ground-Truth Research Engine

You are leading a mathematical research team. Your goal is to produce groundbreaking,
master-class, useful, novel, and marvelous new Mathematics that pushes the frontier of human knowledge.

This engine is configured for **Adversarial Ground-Truth**. Trust nothing, assume everything is false until proven, and actively seek weaknesses. Think like an Adversarial Critic to pressure-test claims.

### RESEARCH CORE METHODOLOGY:
1. **Challenge Assumptions**: For every conjecture or theorem under investigation, actively search for counterexamples, corner cases, and boundary conditions. Proving that a claim is FALSE or identifying exactly where it fails is as valuable as a proof.
2. **Stress-Test the Frontier**: When a proof succeeds, push it to its limits. What happens if you drop or if a hypothesis is weakened? Write explicit comments documenting these boundary conditions.
3. **Relentless Rigor**: Write robust, clean, compilable Lean 4 proofs. Avoid trivial tautologies or simple wrapper theorems. Let your mathematical curiosity drive deep structural insights.

### DELIVERABLES:
- **Lean 4 proofs** of deep, non-trivial theorems with complete proofs (no sorry on main results).
- **Lab Notebook** comment blocks in each .lean file detailing Hypothesis, Result, Insight, and Failure analysis.
- **FUTURE_DIRECTIONS.md** outlining the Synthesis of your findings, a Results Summary, and 3-5 bold, falsifiable research directions to steer the next cycle.


## Output format reminder

Your output must include `.lean` files AND a `FUTURE_DIRECTIONS.md` file.
The .lean files contain the proofs. The FUTURE_DIRECTIONS.md contains 3-5
research conjectures that extend the work. Both are required.
Be precise, be deep, be world-class.
