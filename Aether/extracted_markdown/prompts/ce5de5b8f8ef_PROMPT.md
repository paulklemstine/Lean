
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

**Title**: This cycle pushed the catalog's higher-dimensional persistence backbone
**Domain**: Applications
**Mathematical framing**: # Future Directions — The Boltzmann Bridge: Nerve Interleaving & the f-vector

## Synthesis

This cycle pushed the catalog's higher-dimensional persistence backbone
(`HigherPersistence.lean`'s `Filtration` calculus, `VRfaces`, `vr_mem_iff_diam_le`,
and `euler_char_full_simplex`; `PersistenceStability.lean`'s interleaving/stability
results) in two complementary directions and *closed* them with sorry-free proofs.

First, the **combinatorial Nerve Lemma** (`CechNerve.lean`). We introduced the
Čech filtration `CechFaces ε` — simplices whose vertices share a common closed
`ε`-ball — and proved it is a genuine filtration (downward closed `cech_down_closed`,
monotone `cech_mono`) interleaved with Vietoris–Rips: `Čech(ε) ⊆ VR(2ε)` and,
on nonempty faces, `VR(ε) ⊆ Čech(ε)`, assembled into the classical sandwich
`Čech(ε) ⊆ VR(2ε) ⊆ Čech(2ε)` (`nerve_interleaving`). The single piece of metric
input is the triangle inequality; everything else is the kind of `∀ x ∈ σ`
bookkeeping the `Filtration` framework now makes routine. The structural lesson is
that the *only* place the constant `2` (the interleaving slack) enters is the
forward inclusion, and it is forced purely by `dist x y ≤ dist x c + dist c y`.

Second, the **Euler–Poincaré / f-vector bridge** (`FaceVector.lean`). We defined
the dimension-graded face count `fVector` and the combinatorial Euler
characteristic `eulerCharFin` of an arbitrary finite complex, then proved the
bridge `eulerChar_eq_alt_fVector`: for any complex with a dimension bound, the
Euler characteristic equals the alternating sum of the f-vector. The proof is a
fibrewise regrouping (`Finset.sum_fiberwise_of_maps_to`) by dimension — notably
this holds for *any* finite complex, not just the full simplex; the cancellation
that yields a *small* answer is a separate, complex-specific phenomenon.
Specializing via `fVector_full_simplex` (the f-vector of the full simplex is the
binomial row `C(n,k)`) recovers the catalog's `euler_char_full_simplex` now as a
statement about an actual simplicial complex (`eulerChar_full_simplex`). The
emergent insight tying both threads together: persistent topology is governed by
two orthogonal "ledgers" — a *metric* ledger (distances, which control
interleaving slack) and a *combinatorial* ledger (face counts, which control the
Euler characteristic) — and the `Filtration` abstraction lets each be reasoned
about without touching the other.

What did *not* happen this cycle: we deliberately did not attempt full persistent
*homology* (chain complexes, Betti numbers), because Mathlib's simplicial homology
API is not in a form that plugs into our `Finset`-of-faces model without
substantial scaffolding. The f-vector bridge is the honest, provable shadow of the
Euler–Poincaré theorem available today, and it cleanly signposts what the homology
upgrade would require.

## Results Summary

- `CechFaces`: definition — the Čech (nerve) filtration as the common-ball cover model.
- `cech_down_closed`: proved — Čech faces form an abstract simplicial complex.
- `cech_mono`: proved — the Čech filtration is nested in the radius parameter.
- `cech_subset_vr`: proved — `Čech(ε) ⊆ VR(2ε)`; the forward Nerve interleaving, the sole metric (triangle-inequality) input.
- `vr_subset_cech`: proved — nonempty `VR(ε)` faces are `Čech(ε)` faces (center = any vertex).
- `nerve_interleaving`: proved — the full combinatorial sandwich `Čech(ε) ⊆ VR(2ε) ⊆ Čech(2ε)`.
- `fVector`: definition — dimension-graded face count of a finite complex.
- `eulerCharFin`: definition — combinatorial Euler characteristic of a finite complex.
- `fVector_full_simplex`: proved — `f_k` of the full `n`-simplex is `C(n,k)`.
- `eulerChar_eq_alt_fVector`: proved — Euler characteristic = alternating sum of the f-vector (any finite complex with a dimension bound).
- `eulerChar_full_simplex`: proved — the full nonempty simplex has Euler characteristic `1`, as a complex.

## Research Directions

### Direction 1: The sharp interleaving constant and its boundary
**Hypothesis**: The constant `2` in `cech_subset_vr` is sharp over general
pseudometric spaces — there exist finite configurations with `diamWeight σ = 2ε`
but no common ball of radius `< ε` — yet on Euclidean `ℝ^d` it improves to the
Jung constant `√(2d/(d+1))`, i.e. `Čech(ε) ⊆ VR(c_d · ε)` with `c_d < 2`.
**Test**: Disprove sharpness in general by exhibiting an explicit 3-point metric
forcing the factor `2` (an equilateral triangle in the line metric / a tripod);
then prove the Euclidean improvement for `d = 1` (`c_1 = 1`) as a first case,
formalizing the smallest-enclosing-ball radius of a segment.
**Why now**: `cech_subset_vr` and `vr_subset_cech` isolate exactly where the `2`
is introduced (the forward triangle-inequality step), so a counterexample only has
to defeat that one inclusion, and the Euclidean refinement only needs a center
construction to *replace* the "pick a vertex" center of `vr_subset_cech`.
**If true**: pins the optimal VR-vs-Čech approximation error, the quantity that
controls how much persistence the cheap VR complex can miss.
**If false**: a sub-`2` *general* constant would be a surprising metric fact and
would point to hidden structure in `diamWeight`.

### Direction 2: f-vector monotonicity along the sublevel filtration
**Hypothesis**: For a sublevel `Filtration F`, each `fVector (sublevel faces at t) k`
is a monotone nondecreasing step function of `t`, and the combinatorial Euler
characteristic `eulerCharFin` is a piecewise-constant function of `t` that jumps
only at the finite set of weight values `{F.weight σ}`.
**Test**: Restrict to a finite ambient complex (so all face sets are `Finset`s),
prove `t₁ ≤ t₂ → fVector_at t₁ k ≤ fVector_at t₂ k` from `sublevel_mono`
(monotone `Finset.card` of nested filters), then prove constancy of `eulerCharFin`
on any interval avoiding weight values.
**Why now**: `eulerChar_eq_alt_fVector` already expresses the Euler characteristic
through the f-vector, and `sublevel_mono` already gives the nesting; monotone
`Finset.card` under `⊆` is immediate, so the step-function statement is within reach.
**If true**: yields the *Euler characteristic curve* (ECT/ECC) of a filtration —
a genuine, computable persistence invariant.
**If false**: would reveal that our `eulerCharFin` is not additive across the
filtration, flagging a definitional mismatch with persistent homology.

### Direction 3: The Boltzmann-weighted filtration and the tropical limit
**Hypothesis**: The Boltzmann weight `w_β(σ) = -β⁻¹ log Z(σ)`, for a partition
function `Z` that is supermultiplicative under face inclusion
(`Z(σ) ≥ Z(τ)` for `τ ⊆ σ` ... in the appropriate direction), defines a valid
`Filtration`, and `w_β → diamWeight` pointwise as `β → ∞` when `Z` is the
Gibbs sum `∑ exp(-β · dist)` over the simplex's vertex pairs.
**Test**: Instantiate `Filtration` with `w_β` and discharge `weight_mono` from the
supermultiplicativity hypothesis (a `log`-monotonicity lemma); then prove the
`Filter.Tendsto` statement `w_β σ → diamWeight σ` using `Real.log`-sum-exp →
`max` asymptotics for the finite pairwise-distance set.
**Why now**: `Filtration` abstracts the weight away, so the monotonicity proof is
identical in shape to `diamFiltration.weight_mono`; and the catalog's tropical
thermodynamics (`Catalog/Physics/Bridge.lean`, `uniform_shannon_eq_tropical`)
already houses the `log Z`/min-plus correspondence to import.
**If true**: realizes a thermodynamic limit as a convergence of filtration values,
literally bridging statistical mechanics and persistence.
**If false**: identifies which convexity/supermultiplicativity hypothesis on `Z`
is actually needed, sharpening the "Boltzmann Bridge" hypothesis.

### Direction 4: A cone/contractibility theorem for the Euler characteristic
**Hypothesis**: Coning a finite complex `K` by a fresh apex vertex `v`
(`cone K = K ∪ {σ ∪ {v} | σ ∈ K}`) yields `eulerCharFin (cone K) = 1` regardless
of `K`; equivalently the reduced Euler characteristic of any cone is `0`.
**Test**: Prove `fVector (cone K) k = fVector K k + fVector K (k-1)` (Pascal-style
face accounting: a `k`-face of the cone either avoids `v` or is a `(k-1)`-face plus
`v`), then feed it through `eulerChar_eq_alt_fVector`; the alternating sum
telescopes to `1`.
**Why now**: `eulerChar_eq_alt_fVector` reduces the whole question to an identity
about the f-vector, and the cone recurrence is the *same* binomial/Pascal
bookkeeping that powers `euler_char_full_simplex` (the full simplex is an iterated
cone over a point).
**If true**: gives a reusable contractibility detector — `eulerCharFin = 1` for
every cone — and a clean inductive route to `eulerChar_full_simplex`.
**If false**: would expose a defect in the `eulerCharFin` definition (e.g. mishandling
of the apex or empty face), valuable to catch before building homology on top.

### Direction 5: Functorial persistence module via the nerve interleaving
**Hypothesis**: The assignments `ε ↦ CechFaces ε` and `ε ↦ VRfaces ε` are functors
from the poset `(ℝ, ≤)` to the thin category of `ASC`-inclusions, and the pair
`(cech_subset_vr, vr_subset_cech)` assembles into a natural `δ`-interleaving of
these two persistence modules with `δ = log 2` in the multiplicative parameter
(or additive shift after reparametrizing `ε ↦ 2ε`).
**Test**: Using Mathlib's `CategoryTheory` poset-as-category, package `cech_mono`
and `vr_mono` as functors, then verify the interleaving squares commute (they do,
trivially, since all morphisms are subset inclusions in a thin category).
**Why now**: `PersistenceStability.lean` already proved `ASC.Sub` is a preorder and
exposed the connecting maps; `nerve_interleaving` supplies exactly the two natural
transformations an interleaving needs, so only the categorical packaging remains.
**If true**: lifts the combinatorial sandwich to a bona fide statement in the
category of persistence modules, the correct home for the bottleneck/interleaving
distance.
**If false**: would mean subset inclusions fail some naturality square — impossible
in a thin category, so a failure here would signal a modeling error in how `ASC`
is made into a category, itself a useful diagnostic.

**Concept description**: # Future Directions — The Boltzmann Bridge: Nerve Interleaving & the f-vector

## Synthesis

This cycle pushed the catalog's higher-dimensional persistence backbone
(`HigherPersistence.lean`'s `Filtration` calculus, `VRfaces`, `vr_mem_iff_diam_le`,
and `euler_char_full_simplex`; `PersistenceStability.lean`'s interleaving/stability
results) in two complementary directions and *closed* them with sorry-free proofs.

First, the **combinatorial Nerve Lemma** (`CechNerve.lean`). We introduced the
Čech filtration `CechFaces ε` — simplices whose vertices share a common closed
`ε`-ball — and proved it is a genuine filtration (downward closed `cech_down_closed`,
monotone `cech_mono`) interleaved with Vietoris–Rips: `Čech(ε) ⊆ VR(2ε)` and,
on nonempty faces, `VR(ε) ⊆ Čech(ε)`, assembled into the classical sandwich
`Čech(ε) ⊆ VR(2ε) ⊆ Čech(2ε)` (`nerve_interleaving`). The single piece of metric
input is the triangle inequality; everything else is the kind of `∀ x ∈ σ`
bookkeeping the `Filtration` framework now makes routine. The structural lesson is
that the *only* place the constant `2` (the interleaving slack) enters is the
forward inclusion, and it is forced purely by `dist x y ≤ dist x c + dist c y`.

Second, the **Euler–Poincaré / f-vector bridge** (`FaceVector.lean`). We defined
the dimension-graded face count `fVector` and the combinatorial Euler
characteristic `eulerCharFin` of an arbitrary finite complex, then proved the
bridge `eulerChar_eq_alt_fVector`: for any complex with a dimension bound, the
Euler characteristic equals the alternating sum of the f-vector. The proof is a
fibrewise regrouping (`Finset.sum_fiberwise_of_maps_to`) by dimension — notably
this holds for *any* finite complex, not just the full simplex; the cancellation
that yields a *small* answer is a separate, complex-specific phenomenon.
Specializing via `fVector_full_simplex` (the f-vector of the full simplex is the
binomial row `C(n,k)`) recovers the catalog's `euler_char_full_simplex` now as a
statement about an actual simplicial complex (`eulerChar_full_simplex`). The
emergent insight tying both threads together: persistent topology is governed by
two orthogonal "ledgers" — a *metric* ledger (distances, which control
interleaving slack) and a *combinatorial* ledger (face counts, which control the
Euler characteristic) — and the `Filtration` abstraction lets each be reasoned
about without touching the other.

What did *not* happen this cycle: we deliberately did not attempt full persistent
*homology* (chain complexes, Betti numbers), because Mathlib's simplicial homology
API is not in a form that plugs into our `Finset`-of-faces model without
substantial scaffolding. The f-vector bridge is the honest, provable shadow of the
Euler–Poincaré theorem available today, and it cleanly signposts what the homology
upgrade would require.

## Results Summary

- `CechFaces`: definition — the Čech (nerve) filtration as the common-ball cover model.
- `cech_down_closed`: proved — Čech faces form an abstract simplicial complex.
- `cech_mono`: proved — the Čech filtration is nested in the radius parameter.
- `cech_subset_vr`: proved — `Čech(ε) ⊆ VR(2ε)`; the forward Nerve interleaving, the sole metric (triangle-inequality) input.
- `vr_subset_cech`: proved — nonempty `VR(ε)` faces are `Čech(ε)` faces (center = any vertex).
- `nerve_interleaving`: proved — the full combinatorial sandwich `Čech(ε) ⊆ VR(2ε) ⊆ Čech(2ε)`.
- `fVector`: definition — dimension-graded face count of a finite complex.
- `eulerCharFin`: definition — combinatorial Euler characteristic of a finite complex.
- `fVector_full_simplex`: proved — `f_k` of the full `n`-simplex is `C(n,k)`.
- `eulerChar_eq_alt_fVector`: proved — Euler characteristic = alternating sum of the f-vector (any finite complex with a dimension bound).
- `eulerChar_full_simplex`: proved — the full nonempty simplex has Euler characteristic `1`, as a complex.

## Research Directions

### Direction 1: The sharp interleaving constant and its boundary
**Hypothesis**: The constant `2` in `cech_subset_vr` is sharp over general
pseudometric spaces — there exist finite configurations with `diamWeight σ = 2ε`
but no common ball of radius `< ε` — yet on Euclidean `ℝ^d` it improves to the
Jung constant `√(2d/(d+1))`, i.e. `Čech(ε) ⊆ VR(c_d · ε)` with `c_d < 2`.
**Test**: Disprove sharpness in general by exhibiting an explicit 3-point metric
forcing the factor `2` (an equilateral triangle in the line metric / a tripod);
then prove the Euclidean improvement for `d = 1` (`c_1 = 1`) as a first case,
formalizing the smallest-enclosing-ball radius of a segment.
**Why now**: `cech_subset_vr` and `vr_subset_cech` isolate exactly where the `2`
is introduced (the forward triangle-inequality step), so a counterexample only has
to defeat that one inclusion, and the Euclidean refinement only needs a center
construction to *replace* the "pick a vertex" center of `vr_subset_cech`.
**If true**: pins the optimal VR-vs-Čech approximation error, the quantity that
controls how much persistence the cheap VR complex can miss.
**If false**: a sub-`2` *general* constant would be a surprising metric fact and
would point to hidden structure in `diamWeight`.

### Direction 2: f-vector monotonicity along the sublevel filtration
**Hypothesis**: For a sublevel `Filtration F`, each `fVector (sublevel faces at t) k`
is a monotone nondecreasing step function of `t`, and the combinatorial Euler
characteristic `eulerCharFin` is a piecewise-constant function of `t` that jumps
only at the finite set of weight values `{F.weight σ}`.
**Test**: Restrict to a finite ambient complex (so all face sets are `Finset`s),
prove `t₁ ≤ t₂ → fVector_at t₁ k ≤ fVector_at t₂ k` from `sublevel_mono`
(monotone `Finset.card` of nested filters), then prove constancy of `eulerCharFin`
on any interval avoiding weight values.
**Why now**: `eulerChar_eq_alt_fVector` already expresses the Euler characteristic
through the f-vector, and `sublevel_mono` already gives the nesting; monotone
`Finset.card` under `⊆` is immediate, so the step-function statement is within reach.
**If true**: yields the *Euler characteristic curve* (ECT/ECC) of a filtration —
a genuine, computable persistence invariant.
**If false**: would reveal that our `eulerCharFin` is not additive across the
filtration, flagging a definitional mismatch with persistent homology.

### Direction 3: The Boltzmann-weighted filtration and the tropical limit
**Hypothesis**: The Boltzmann weight `w_β(σ) = -β⁻¹ log Z(σ)`, for a partition
function `Z` that is supermultiplicative under face inclusion
(`Z(σ) ≥ Z(τ)` for `τ ⊆ σ` ... in the appropriate direction), defines a valid
`Filtration`, and `w_β → diamWeight` pointwise as `β → ∞` when `Z` is the
Gibbs sum `∑ exp(-β · dist)` over the simplex's vertex pairs.
**Test**: Instantiate `Filtration` with `w_β` and discharge `weight_mono` from the
supermultiplicativity hypothesis (a `log`-monotonicity lemma); then prove the
`Filter.Tendsto` statement `w_β σ → diamWeight σ` using `Real.log`-sum-exp →
`max` asymptotics for the finite pairwise-distance set.
**Why now**: `Filtration` abstracts the weight away, so the monotonicity proof is
identical in shape to `diamFiltration.weight_mono`; and the catalog's tropical
thermodynamics (`Catalog/Physics/Bridge.lean`, `uniform_shannon_eq_tropical`)
already houses the `log Z`/min-plus correspondence to import.
**If true**: realizes a thermodynamic limit as a convergence of filtration values,
literally bridging statistical mechanics and persistence.
**If false**: identifies which convexity/supermultiplicativity hypothesis on `Z`
is actually needed, sharpening the "Boltzmann Bridge" hypothesis.

### Direction 4: A cone/contractibility theorem for the Euler characteristic
**Hypothesis**: Coning a finite complex `K` by a fresh apex vertex `v`
(`cone K = K ∪ {σ ∪ {v} | σ ∈ K}`) yields `eulerCharFin (cone K) = 1` regardless
of `K`; equivalently the reduced Euler characteristic of any cone is `0`.
**Test**: Prove `fVector (cone K) k = fVector K k + fVector K (k-1)` (Pascal-style
face accounting: a `k`-face of the cone either avoids `v` or is a `(k-1)`-face plus
`v`), then feed it through `eulerChar_eq_alt_fVector`; the alternating sum
telescopes to `1`.
**Why now**: `eulerChar_eq_alt_fVector` reduces the whole question to an identity
about the f-vector, and the cone recurrence is the *same* binomial/Pascal
bookkeeping that powers `euler_char_full_simplex` (the full simplex is an iterated
cone over a point).
**If true**: gives a reusable contractibility detector — `eulerCharFin = 1` for
every cone — and a clean inductive route to `eulerChar_full_simplex`.
**If false**: would expose a defect in the `eulerCharFin` definition (e.g. mishandling
of the apex or empty face), valuable to catch before building homology on top.

### Direction 5: Functorial persistence module via the nerve interleaving
**Hypothesis**: The assignments `ε ↦ CechFaces ε` and `ε ↦ VRfaces ε` are functors
from the poset `(ℝ, ≤)` to the thin category of `ASC`-inclusions, and the pair
`(cech_subset_vr, vr_subset_cech)` assembles into a natural `δ`-interleaving of
these two persistence modules with `δ = log 2` in the multiplicative parameter
(or additive shift after reparametrizing `ε ↦ 2ε`).
**Test**: Using Mathlib's `CategoryTheory` poset-as-category, package `cech_mono`
and `vr_mono` as functors, then verify the interleaving squares commute (they do,
trivially, since all morphisms are subset inclusions in a thin category).
**Why now**: `PersistenceStability.lean` already proved `ASC.Sub` is a preorder and
exposed the connecting maps; `nerve_interleaving` supplies exactly the two natural
transformations an interleaving needs, so only the categorical packaging remains.
**If true**: lifts the combinatorial sandwich to a bona fide statement in the
category of persistence modules, the correct home for the bottleneck/interleaving
distance.
**If false**: would mean subset inclusions fail some naturality square — impossible
in a thin category, so a failure here would signal a modeling error in how `ASC`
is made into a category, itself a useful diagnostic.

**Novelty estimate**: 0.75
**Breakthrough potential**: 0.75
Research domain: Applications
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
