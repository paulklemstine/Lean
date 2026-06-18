
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

**Title**: The previous cycles built the *spectral depth threshold* skeleton
**Domain**: Applications
**Mathematical framing**: # Future Directions — Hodge–Laplacian Message Passing, Third Cycle

## Synthesis

The previous cycles built the *spectral depth threshold* skeleton
(`HodgeSpectralThreshold.lean`): the combinatorial Hodge Laplacian `L = BᵀB`, the
message-passing layer `mpStep L α x = x - α(Lx)`, the discrete Hodge theorem
`Lx = 0 ↔ Bx = 0`, the Dirichlet-energy identity, the one-layer spectral contraction,
and the finite depth threshold. Those results all live at the level of a *single
trajectory's energy*.

This cycle promotes that scalar picture to the **global dynamical structure** of the
message-passing semigroup, in the new self-contained file
`HodgeMessagePassingDynamics.lean`. The pivot is the observation that `mpStep` is a
*linear* operator, not merely energy-contracting. From linearity we obtain:

1. **Linearity, single layer and depth-`k` iterate** — `mpStep_add`, `mpStep_smul`,
   `mpStep_sub`, `mpStep_iterate_add`, `mpStep_iterate_sub`.
2. **The Hodge decomposition flow** — `hodge_decomposition_dynamics`: writing a signal
   `x = h + r` with `h` harmonic, the layer transports the harmonic part as a frozen
   constant and lets the residual evolve on its own,
   `(mpStep)^[k](h + r) = h + (mpStep)^[k] r`.
3. **Oversmoothing as convergence to the harmonic projection** — `oversmoothing_limit`:
   under a residual contraction `ρ < 1`, every input is driven within `ε` of its
   harmonic (cohomological) component in finitely many layers.
4. **Trajectory stability** — `trajectory_stability`: any two inputs have trajectories
   whose energy gap decays as `ρ^k`; the dynamics is a contraction *modulo* the harmonic
   kernel.

The conceptual payoff: **oversmoothing is not a defect to be patched but the exact
statement of a discrete Hodge decomposition for the message-passing semigroup** — the
operator's fixed set is the cohomology group and its complement is uniformly contracted.

## Results Summary

All eight theorems in `HodgeMessagePassingDynamics.lean` are proven `sorry`-free and
depend only on `propext`, `Classical.choice`, `Quot.sound`. The file is self-contained
(`import Mathlib` only), re-stating the four catalog facts it builds on
(`mpStep_iterate_fixes_harmonic`, `quadform_iterate_bound`, `spectral_depth_threshold`,
and the `mpStep` definition) and then proving the genuinely new linearity, decomposition,
oversmoothing, and stability results.

## Research Directions

### 1. A quantitative, depth-explicit oversmoothing rate with an operator norm

The current `oversmoothing_limit` is an `∃N` statement; it hides the dependence of `N`
on `ε`, `ρ`, and the residual energy `r ⬝ᵥ r`. The next step is to prove the *explicit*
threshold `N(ε) = ⌈log(ε / (r⬝ᵥr)) / log ρ⌉` makes the residual energy `≤ ε`, turning the
limit into a closed-form depth budget. **The key insight is** that `quadform_iterate_bound`
already gives `ρ^k (r⬝ᵥr)` exactly, so the only missing piece is a clean
`Nat.ceil`/`Real.log` inversion lemma — no new dynamics. **Why now?** With the
decomposition flow proven, the residual is literally `(mpStep)^[k] r`, so the explicit
rate is a one-variable real-analysis exercise rather than a statement about the network;
this is the natural sharpening a downstream "depth-vs-accuracy" theorem needs.

### 2. The two-sided spectral sandwich: a lower bound forbidding *over*-contraction

We bound the residual energy from above. A complementary, falsifiable claim is a *lower*
bound: with `μ(x⬝ᵥx) ≤ ⟨x,Lx⟩` (spectral gap) and admissible step, a single layer cannot
contract faster than `(1 - αλ)²`, i.e. `(1-αλ)²(x⬝ᵥx) ≤ mpStep x ⬝ᵥ mpStep x` on the
energy-carrying complement. **The key insight is** that the same energy expansion
`quadform_mpStep` that yields the upper contraction, read with the reverse operator
inequality, yields the lower one — the two bounds are the two sides of one quadratic.
**Why now?** Establishing both bounds pins the per-layer factor inside an interval and is
the precise hypothesis under which "harmonic component is the *only* survivor" becomes an
iff rather than an implication, closing the characterization of the limit set.

### 3. Heat-semigroup consistency: `mpStep` as an Euler step of the Hodge heat flow

Message passing `x ↦ x - α(Lx)` is the explicit Euler discretization of the Hodge heat
equation `ẋ = -Lx`, whose exact flow is `e^{-tL}`. Conjecture: for fixed `t = kα` and
`α → 0` (equivalently `k → ∞`), `(mpStep L α)^[k] x → e^{-tL} x`, and both share the same
fixed set (the harmonic kernel) and the same projection limit as `t → ∞`. **The key
insight is** that `hodge_decomposition_dynamics` already proves the discrete flow respects
the Hodge splitting *exactly at every step*, which is precisely the invariant the
continuous semigroup preserves — so the limit is a convergence-of-Euler argument on the
contracting complement only. **Why now?** Mathlib has the matrix exponential and its
basic semigroup laws; bridging the discrete catalog operator to `Matrix.exp (-t • L)`
connects this MachineLearning thread to the analytic PDE/semigroup machinery and makes the
"oversmoothing = heat death" slogan a theorem.

### 4. Residual connections provably defeat oversmoothing

Add a skip connection: `mpStepRes L α β x = (1+β)x - α(Lx)` (or `x + β(x - mpStep)`).
Conjecture: there is a regime of `β > 0` in which the energy-carrying complement is
*non-contracting* (spectral radius `≥ 1`) while the harmonic part is still preserved, so
deep residual networks do **not** collapse to the harmonic projection. **The key insight
is** that the same energy expansion that gave the contraction factor `1 - αμ(2-αλ)` gives,
for the residual layer, a factor that crosses `1` exactly when `β` exceeds an explicit
spectral-gap threshold — a sign-flip in one `nlinarith`-provable inequality. **Why now?**
This is the cleanest formal explanation of why residual/initial-connection GNNs avoid
oversmoothing, and it reuses the entire existing energy-expansion toolchain verbatim; the
only new object is the one-parameter family of layers.

### 5. From the up-Laplacian to the full Hodge Laplacian and Betti-rank invariance

The catalog already has `HodgeFullDecomposition.lean` (full `L = BᵀB + CCᵀ`) and
`HodgeBettiRank.lean` (kernel rank = Betti number). Conjecture: the decomposition flow
and oversmoothing limit lift verbatim to the *full* Hodge Laplacian, and the dimension of
the limit set equals the `k`-th Betti number — so the asymptotic output of a deep
simplicial network is a representation of the cohomology group `H^k`, a topological
invariant. **The key insight is** that all four new theorems used only `L *ᵥ h = 0` and a
scalar contraction, never the *up*-specific structure `L = BᵀB`; replacing `L` by the full
symmetric PSD Hodge Laplacian changes nothing in the proofs but changes the kernel's
meaning from "harmonic up-cochains" to "genuine harmonic representatives of `H^k`. **Why
now?** This is the cross-domain capstone: it fuses the MachineLearning oversmoothing
program with the topological Betti-rank results already in the catalog, yielding the
statement "deep Hodge message passing computes cohomology."

**Concept description**: # Future Directions — Hodge–Laplacian Message Passing, Third Cycle

## Synthesis

The previous cycles built the *spectral depth threshold* skeleton
(`HodgeSpectralThreshold.lean`): the combinatorial Hodge Laplacian `L = BᵀB`, the
message-passing layer `mpStep L α x = x - α(Lx)`, the discrete Hodge theorem
`Lx = 0 ↔ Bx = 0`, the Dirichlet-energy identity, the one-layer spectral contraction,
and the finite depth threshold. Those results all live at the level of a *single
trajectory's energy*.

This cycle promotes that scalar picture to the **global dynamical structure** of the
message-passing semigroup, in the new self-contained file
`HodgeMessagePassingDynamics.lean`. The pivot is the observation that `mpStep` is a
*linear* operator, not merely energy-contracting. From linearity we obtain:

1. **Linearity, single layer and depth-`k` iterate** — `mpStep_add`, `mpStep_smul`,
   `mpStep_sub`, `mpStep_iterate_add`, `mpStep_iterate_sub`.
2. **The Hodge decomposition flow** — `hodge_decomposition_dynamics`: writing a signal
   `x = h + r` with `h` harmonic, the layer transports the harmonic part as a frozen
   constant and lets the residual evolve on its own,
   `(mpStep)^[k](h + r) = h + (mpStep)^[k] r`.
3. **Oversmoothing as convergence to the harmonic projection** — `oversmoothing_limit`:
   under a residual contraction `ρ < 1`, every input is driven within `ε` of its
   harmonic (cohomological) component in finitely many layers.
4. **Trajectory stability** — `trajectory_stability`: any two inputs have trajectories
   whose energy gap decays as `ρ^k`; the dynamics is a contraction *modulo* the harmonic
   kernel.

The conceptual payoff: **oversmoothing is not a defect to be patched but the exact
statement of a discrete Hodge decomposition for the message-passing semigroup** — the
operator's fixed set is the cohomology group and its complement is uniformly contracted.

## Results Summary

All eight theorems in `HodgeMessagePassingDynamics.lean` are proven `sorry`-free and
depend only on `propext`, `Classical.choice`, `Quot.sound`. The file is self-contained
(`import Mathlib` only), re-stating the four catalog facts it builds on
(`mpStep_iterate_fixes_harmonic`, `quadform_iterate_bound`, `spectral_depth_threshold`,
and the `mpStep` definition) and then proving the genuinely new linearity, decomposition,
oversmoothing, and stability results.

## Research Directions

### 1. A quantitative, depth-explicit oversmoothing rate with an operator norm

The current `oversmoothing_limit` is an `∃N` statement; it hides the dependence of `N`
on `ε`, `ρ`, and the residual energy `r ⬝ᵥ r`. The next step is to prove the *explicit*
threshold `N(ε) = ⌈log(ε / (r⬝ᵥr)) / log ρ⌉` makes the residual energy `≤ ε`, turning the
limit into a closed-form depth budget. **The key insight is** that `quadform_iterate_bound`
already gives `ρ^k (r⬝ᵥr)` exactly, so the only missing piece is a clean
`Nat.ceil`/`Real.log` inversion lemma — no new dynamics. **Why now?** With the
decomposition flow proven, the residual is literally `(mpStep)^[k] r`, so the explicit
rate is a one-variable real-analysis exercise rather than a statement about the network;
this is the natural sharpening a downstream "depth-vs-accuracy" theorem needs.

### 2. The two-sided spectral sandwich: a lower bound forbidding *over*-contraction

We bound the residual energy from above. A complementary, falsifiable claim is a *lower*
bound: with `μ(x⬝ᵥx) ≤ ⟨x,Lx⟩` (spectral gap) and admissible step, a single layer cannot
contract faster than `(1 - αλ)²`, i.e. `(1-αλ)²(x⬝ᵥx) ≤ mpStep x ⬝ᵥ mpStep x` on the
energy-carrying complement. **The key insight is** that the same energy expansion
`quadform_mpStep` that yields the upper contraction, read with the reverse operator
inequality, yields the lower one — the two bounds are the two sides of one quadratic.
**Why now?** Establishing both bounds pins the per-layer factor inside an interval and is
the precise hypothesis under which "harmonic component is the *only* survivor" becomes an
iff rather than an implication, closing the characterization of the limit set.

### 3. Heat-semigroup consistency: `mpStep` as an Euler step of the Hodge heat flow

Message passing `x ↦ x - α(Lx)` is the explicit Euler discretization of the Hodge heat
equation `ẋ = -Lx`, whose exact flow is `e^{-tL}`. Conjecture: for fixed `t = kα` and
`α → 0` (equivalently `k → ∞`), `(mpStep L α)^[k] x → e^{-tL} x`, and both share the same
fixed set (the harmonic kernel) and the same projection limit as `t → ∞`. **The key
insight is** that `hodge_decomposition_dynamics` already proves the discrete flow respects
the Hodge splitting *exactly at every step*, which is precisely the invariant the
continuous semigroup preserves — so the limit is a convergence-of-Euler argument on the
contracting complement only. **Why now?** Mathlib has the matrix exponential and its
basic semigroup laws; bridging the discrete catalog operator to `Matrix.exp (-t • L)`
connects this MachineLearning thread to the analytic PDE/semigroup machinery and makes the
"oversmoothing = heat death" slogan a theorem.

### 4. Residual connections provably defeat oversmoothing

Add a skip connection: `mpStepRes L α β x = (1+β)x - α(Lx)` (or `x + β(x - mpStep)`).
Conjecture: there is a regime of `β > 0` in which the energy-carrying complement is
*non-contracting* (spectral radius `≥ 1`) while the harmonic part is still preserved, so
deep residual networks do **not** collapse to the harmonic projection. **The key insight
is** that the same energy expansion that gave the contraction factor `1 - αμ(2-αλ)` gives,
for the residual layer, a factor that crosses `1` exactly when `β` exceeds an explicit
spectral-gap threshold — a sign-flip in one `nlinarith`-provable inequality. **Why now?**
This is the cleanest formal explanation of why residual/initial-connection GNNs avoid
oversmoothing, and it reuses the entire existing energy-expansion toolchain verbatim; the
only new object is the one-parameter family of layers.

### 5. From the up-Laplacian to the full Hodge Laplacian and Betti-rank invariance

The catalog already has `HodgeFullDecomposition.lean` (full `L = BᵀB + CCᵀ`) and
`HodgeBettiRank.lean` (kernel rank = Betti number). Conjecture: the decomposition flow
and oversmoothing limit lift verbatim to the *full* Hodge Laplacian, and the dimension of
the limit set equals the `k`-th Betti number — so the asymptotic output of a deep
simplicial network is a representation of the cohomology group `H^k`, a topological
invariant. **The key insight is** that all four new theorems used only `L *ᵥ h = 0` and a
scalar contraction, never the *up*-specific structure `L = BᵀB`; replacing `L` by the full
symmetric PSD Hodge Laplacian changes nothing in the proofs but changes the kernel's
meaning from "harmonic up-cochains" to "genuine harmonic representatives of `H^k`. **Why
now?** This is the cross-domain capstone: it fuses the MachineLearning oversmoothing
program with the topological Betti-rank results already in the catalog, yielding the
statement "deep Hodge message passing computes cohomology."

**Novelty estimate**: 0.75
**Breakthrough potential**: 0.75
Research domain: Applications
Research mode: team




### Recent Discoveries in Catalog
No previous research cycles completed yet. This is a cold start — prioritize sorry_fill on the priority targets (CarmichaelComposite, Fib_gcd_identity) to close known open problems, or target cross-domain bridge theorems for novelty.


## v13 Depth Requirements -- Conceptual Unifier: Homotopy & Path Spaces Research Engine

You are leading a mathematical research team. Your goal is to produce groundbreaking,
master-class, useful, novel, and marvelous new Mathematics that pushes the frontier of human knowledge.

This engine is configured for **Conceptual Unification (Homotopy & Path Spaces)**. Explore topological paths, homotopical structures, and higher categorical localization (such as infinity-categories, model categories, and path spaces).

### RESEARCH CORE METHODOLOGY:
1. **Homotopy & Deformation**: Model mathematical structures and mappings up to continuous deformation or equivalence. Study path spaces, fundamental groupoids, and higher-dimensional homotopical invariants.
2. **Localization & Universality**: Define localizations that invert specific classes of morphisms, exposing the underlying universal homotopy properties of your mathematical structures.
3. **Higher Categorical Invariance**: Frame results through the lens of infinity-categories or model categories, ensuring definitions are invariant under homotopical equivalence.

### DELIVERABLES:
- **Lean 4 proofs** of deep, non-trivial theorems with complete proofs (no sorry on main results).
- **Lab Notebook** comment blocks in each .lean file detailing Hypothesis, Result, Insight, and Failure analysis.
- **FUTURE_DIRECTIONS.md** outlining the Synthesis of your findings, a Results Summary, and 3-5 bold, falsifiable research directions to steer the next cycle.


## Output format reminder

Your output must include `.lean` files AND a `FUTURE_DIRECTIONS.md` file.
The .lean files contain the proofs. The FUTURE_DIRECTIONS.md contains 3-5
research conjectures that extend the work. Both are required.
Be precise, be deep, be world-class.
