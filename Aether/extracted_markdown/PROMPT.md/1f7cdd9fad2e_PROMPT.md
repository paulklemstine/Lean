
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

**Title**: The file `Core.lean` distills the (empirical, ML-flavored) conjecture
**Domain**: Novelty
**Mathematical framing**: # Future Directions — Universal Scaling of Minimal PDE-Solver Size at a Spectral Phase Transition

## Synthesis

The file `Core.lean` distills the (empirical, ML-flavored) conjecture
*"minimal neural-operator size diverges as a universal power law near an
operator-spectrum phase transition"* into a fully formal, machine-checked core.
The central object is the **minimal iteration / depth count**
`Nmin ρ ε = least n with ρ^n ≤ ε`, the scalar shadow of how many Neumann /
power-iteration terms (equivalently, how much polynomial depth) a solver needs to
invert a discretized solution operator with contraction factor `ρ = 1 - g`,
where `g` is the spectral gap.

The headline theorem `Nmin_sandwich` proves a **two-sided power law**

```
(1 - ε)/g  ≤  Nmin (1-g) ε  ≤  log(1/ε)/g + 1 ,
```

so the size diverges as `g⁻¹` with a *class-universal exponent* and an
*ε-dependent prefactor band* `[1-ε, log(1/ε)]`. The whole "critical exponent"
content collapses onto two elementary inequalities — Bernoulli
`1 - n·g ≤ (1-g)^n` (which *forces* divergence) and `1 - g ≤ e^{-g}` (which
*controls* it). This separation is the engine behind every corollary:

* `Nmin_sandwich_accelerated` — feeding the *square-root* contraction `1 - √g`
  (Chebyshev / conjugate-gradient acceleration) halves the exponent to `1/2`.
* `power_law_control` / `power_law_control_accelerated` — composing with a gap
  `g = D^α` that closes as a power of the control parameter `D = |λ - λc|` yields
  divergence `D^{-α}` (unaccelerated) versus `D^{-α/2}` (accelerated), i.e.
  critical exponents `ν = α` versus `ν = α/2`.
* `accelerated_exponent_lt` — the two universality classes are genuinely
  distinguished: `α/2 < α`.
* `power_law_discretization_independent` — replacing `g` by `c·D^α` for any
  microscopic discretization constant `c ∈ (0,1]` leaves the exponent equal to
  `α`; only the prefactor moves. This is the renormalization-style statement that
  the exponent is independent of microscopic details.

A computable rational analogue `NminQ` makes the divergence concrete: as the gap
shrinks tenfold (`ρ = 0.9 → 0.99`) the count grows ≈ tenfold (`44 → 459`),
numerically confirming the `g⁻¹` law.

## Results Summary

| Theorem | Statement | Exponent ν |
|---|---|---|
| `Nmin_sandwich` | `(1-ε)/g ≤ Nmin (1-g) ε ≤ log(1/ε)/g + 1` | 1 (in `g`) |
| `Nmin_sandwich_accelerated` | same with `g ↦ √g` | 1/2 (in `g`) |
| `power_law_control` | `Nmin ~ D^{-α}` for `g = D^α` | `α` |
| `power_law_control_accelerated` | `Nmin ~ D^{-α/2}` | `α/2` |
| `accelerated_exponent_lt` | `α/2 < α` | — |
| `power_law_discretization_independent` | `g = c·D^α ⇒` exponent `= α` | `α` (∀ `c`) |

All proofs are `sorry`-free and use only the standard axioms
(`propext`, `Classical.choice`, `Quot.sound`).

## Research Directions

### 1. Logarithmic correction at the exact critical point (a sharper ceiling)

The current upper bound `log(1/ε)/g + 1` and lower bound `(1-ε)/g` pin down the
exponent but leave a constant-factor gap of `log(1/ε)/(1-ε)` in the prefactor.
Conjecture: there is a *sharp* asymptotic `Nmin (1-g) ε = log(1/ε)/g · (1 + o(1))`
as `g → 0⁺` with `ε` fixed, and the next-order term is a pure logarithmic
correction independent of `g`. **The key insight is** that
`-1/log(1-g) = 1/g · (1 - g/2 + o(g))`, so the gap between the two sandwich
bounds is itself governed by a convergent power series in `g`, meaning the
prefactor band must collapse to a single value in the limit. **Why now?** We
already have both one-sided bounds formalized; tightening to a genuine
`Filter.Tendsto`/`IsEquivalent` statement only requires the `Real.log (1 - g)`
expansion, which is in Mathlib, and would upgrade the qualitative power law to a
quantitative scaling collapse — falsifiable by exhibiting any `ε` for which the
ratio `Nmin·g / log(1/ε)` fails to converge to 1.

### 2. The square-root acceleration barrier is optimal (a lower bound across all schemes)

We proved that acceleration `g ↦ √g` halves the exponent, but not that `1/2` is
the *best possible* exponent for any polynomial scheme. Conjecture: among all
contraction families `ρ(g)` realizable by degree-`d` polynomial solvers of a
self-adjoint operator with gap `g`, no scheme achieves exponent below `1/2`; i.e.
`Nmin ≥ c·g^{-1/2}` uniformly. **The key insight is** that the Chebyshev
polynomials are extremal for the min-max problem `min_p max_{x∈[g,1]} |1 - x·p(x)|`,
so the `g^{-1/2}` rate is not an artifact of our particular `1 - √g` model but a
hard floor coming from approximation theory. **Why now?** Mathlib's Chebyshev
polynomial library plus our `Nmin` skeleton make the extremality argument
self-contained; the conjecture is falsifiable by constructing a polynomial family
with provably smaller asymptotic degree, which would overturn 70 years of
iterative-solver lower-bound folklore.

### 3. Exponent additivity under composed (tensor) phase transitions

Real multiphysics solvers face *several* gaps closing at once (e.g. an elliptic
gap and a parabolic gap). Model this by the product contraction
`ρ = (1 - g₁)(1 - g₂)` with independent gaps `g₁ = D^{α₁}`, `g₂ = D^{α₂}`.
Conjecture: the composed exponent is `ν = max(α₁, α₂)`, *not* `α₁ + α₂` — the
slowest-closing gap dominates, exactly like a rate-limiting step. **The key
insight is** that `1 - (1-g₁)(1-g₂) = g₁ + g₂ - g₁g₂ ≈ g₁ + g₂`, whose power-law
exponent near `D → 0` is set by the larger of `α₁, α₂`, so divergence is governed
by a single critical mode even in a coupled system. **Why now?** Our
`Nmin_sandwich` already accepts an arbitrary effective gap, so the result reduces
to an elementary `D^{α₁} + D^{α₂} ≍ D^{min(α₁,α₂)}` estimate; it is falsifiable by
any coupled model whose measured exponent exceeds `max(α₁, α₂)`.

### 4. Width–depth tradeoff: a conserved product near criticality

We modeled "solver size" as a single depth-like count. In practice architectures
trade width `W` against depth `L`. Conjecture: near `λc` there is a conserved
quantity `W^a · L^b ~ |λ - λc|^{-ν}` so that for fixed target error the feasible
`(W, L)` pairs lie on a hyperbola whose position diverges with the same exponent
`ν` derived here, independent of how the budget is split. **The key insight is**
that a degree-`n` polynomial of the operator can be realized either by `n`
sequential applications (depth) or by a width-`n` parallel Krylov basis, so the
*product* — not either factor alone — is what the spectral gap forces to diverge.
**Why now?** The `Nmin` count is exactly the polynomial degree, the invariant
both realizations share; formalizing the two realizations as bounds on `W·L`
turns the heuristic "expressivity = degree" into a theorem, falsifiable by an
architecture that beats the hyperbola at fixed error.

### 5. Non-self-adjoint exceptional points give a strictly larger exponent

For *defective* (Jordan-block / exceptional-point) operators the resolvent norm
blows up faster than `1/g` because of nilpotent coupling between coalescing modes.
Conjecture: for a size-`m` Jordan block whose eigenvalue approaches the spectrum
edge as `D^α`, the minimal solver size diverges as `D^{-α·m}` — the exponent is
multiplied by the Jordan size, a strictly different universality class from the
diagonalizable (`m = 1`) case. **The key insight is** that
`‖(A - z)^{-1}‖ ∼ g^{-m}` for an `m`-fold defective eigenvalue, so the *effective*
contraction seen by any polynomial solver is `1 - g^{m}` rather than `1 - g`,
feeding straight into our sandwich with exponent `α·m`. **Why now?** The model
needs only a scalar effective-gap input, which `Core.lean` already isolates, so
the conjecture is testable by instantiating the sandwich with `g^m` and is
falsifiable by any defective family whose measured exponent stays at `α`,
independent of Jordan size.

**Concept description**: # Future Directions — Universal Scaling of Minimal PDE-Solver Size at a Spectral Phase Transition

## Synthesis

The file `Core.lean` distills the (empirical, ML-flavored) conjecture
*"minimal neural-operator size diverges as a universal power law near an
operator-spectrum phase transition"* into a fully formal, machine-checked core.
The central object is the **minimal iteration / depth count**
`Nmin ρ ε = least n with ρ^n ≤ ε`, the scalar shadow of how many Neumann /
power-iteration terms (equivalently, how much polynomial depth) a solver needs to
invert a discretized solution operator with contraction factor `ρ = 1 - g`,
where `g` is the spectral gap.

The headline theorem `Nmin_sandwich` proves a **two-sided power law**

```
(1 - ε)/g  ≤  Nmin (1-g) ε  ≤  log(1/ε)/g + 1 ,
```

so the size diverges as `g⁻¹` with a *class-universal exponent* and an
*ε-dependent prefactor band* `[1-ε, log(1/ε)]`. The whole "critical exponent"
content collapses onto two elementary inequalities — Bernoulli
`1 - n·g ≤ (1-g)^n` (which *forces* divergence) and `1 - g ≤ e^{-g}` (which
*controls* it). This separation is the engine behind every corollary:

* `Nmin_sandwich_accelerated` — feeding the *square-root* contraction `1 - √g`
  (Chebyshev / conjugate-gradient acceleration) halves the exponent to `1/2`.
* `power_law_control` / `power_law_control_accelerated` — composing with a gap
  `g = D^α` that closes as a power of the control parameter `D = |λ - λc|` yields
  divergence `D^{-α}` (unaccelerated) versus `D^{-α/2}` (accelerated), i.e.
  critical exponents `ν = α` versus `ν = α/2`.
* `accelerated_exponent_lt` — the two universality classes are genuinely
  distinguished: `α/2 < α`.
* `power_law_discretization_independent` — replacing `g` by `c·D^α` for any
  microscopic discretization constant `c ∈ (0,1]` leaves the exponent equal to
  `α`; only the prefactor moves. This is the renormalization-style statement that
  the exponent is independent of microscopic details.

A computable rational analogue `NminQ` makes the divergence concrete: as the gap
shrinks tenfold (`ρ = 0.9 → 0.99`) the count grows ≈ tenfold (`44 → 459`),
numerically confirming the `g⁻¹` law.

## Results Summary

| Theorem | Statement | Exponent ν |
|---|---|---|
| `Nmin_sandwich` | `(1-ε)/g ≤ Nmin (1-g) ε ≤ log(1/ε)/g + 1` | 1 (in `g`) |
| `Nmin_sandwich_accelerated` | same with `g ↦ √g` | 1/2 (in `g`) |
| `power_law_control` | `Nmin ~ D^{-α}` for `g = D^α` | `α` |
| `power_law_control_accelerated` | `Nmin ~ D^{-α/2}` | `α/2` |
| `accelerated_exponent_lt` | `α/2 < α` | — |
| `power_law_discretization_independent` | `g = c·D^α ⇒` exponent `= α` | `α` (∀ `c`) |

All proofs are `sorry`-free and use only the standard axioms
(`propext`, `Classical.choice`, `Quot.sound`).

## Research Directions

### 1. Logarithmic correction at the exact critical point (a sharper ceiling)

The current upper bound `log(1/ε)/g + 1` and lower bound `(1-ε)/g` pin down the
exponent but leave a constant-factor gap of `log(1/ε)/(1-ε)` in the prefactor.
Conjecture: there is a *sharp* asymptotic `Nmin (1-g) ε = log(1/ε)/g · (1 + o(1))`
as `g → 0⁺` with `ε` fixed, and the next-order term is a pure logarithmic
correction independent of `g`. **The key insight is** that
`-1/log(1-g) = 1/g · (1 - g/2 + o(g))`, so the gap between the two sandwich
bounds is itself governed by a convergent power series in `g`, meaning the
prefactor band must collapse to a single value in the limit. **Why now?** We
already have both one-sided bounds formalized; tightening to a genuine
`Filter.Tendsto`/`IsEquivalent` statement only requires the `Real.log (1 - g)`
expansion, which is in Mathlib, and would upgrade the qualitative power law to a
quantitative scaling collapse — falsifiable by exhibiting any `ε` for which the
ratio `Nmin·g / log(1/ε)` fails to converge to 1.

### 2. The square-root acceleration barrier is optimal (a lower bound across all schemes)

We proved that acceleration `g ↦ √g` halves the exponent, but not that `1/2` is
the *best possible* exponent for any polynomial scheme. Conjecture: among all
contraction families `ρ(g)` realizable by degree-`d` polynomial solvers of a
self-adjoint operator with gap `g`, no scheme achieves exponent below `1/2`; i.e.
`Nmin ≥ c·g^{-1/2}` uniformly. **The key insight is** that the Chebyshev
polynomials are extremal for the min-max problem `min_p max_{x∈[g,1]} |1 - x·p(x)|`,
so the `g^{-1/2}` rate is not an artifact of our particular `1 - √g` model but a
hard floor coming from approximation theory. **Why now?** Mathlib's Chebyshev
polynomial library plus our `Nmin` skeleton make the extremality argument
self-contained; the conjecture is falsifiable by constructing a polynomial family
with provably smaller asymptotic degree, which would overturn 70 years of
iterative-solver lower-bound folklore.

### 3. Exponent additivity under composed (tensor) phase transitions

Real multiphysics solvers face *several* gaps closing at once (e.g. an elliptic
gap and a parabolic gap). Model this by the product contraction
`ρ = (1 - g₁)(1 - g₂)` with independent gaps `g₁ = D^{α₁}`, `g₂ = D^{α₂}`.
Conjecture: the composed exponent is `ν = max(α₁, α₂)`, *not* `α₁ + α₂` — the
slowest-closing gap dominates, exactly like a rate-limiting step. **The key
insight is** that `1 - (1-g₁)(1-g₂) = g₁ + g₂ - g₁g₂ ≈ g₁ + g₂`, whose power-law
exponent near `D → 0` is set by the larger of `α₁, α₂`, so divergence is governed
by a single critical mode even in a coupled system. **Why now?** Our
`Nmin_sandwich` already accepts an arbitrary effective gap, so the result reduces
to an elementary `D^{α₁} + D^{α₂} ≍ D^{min(α₁,α₂)}` estimate; it is falsifiable by
any coupled model whose measured exponent exceeds `max(α₁, α₂)`.

### 4. Width–depth tradeoff: a conserved product near criticality

We modeled "solver size" as a single depth-like count. In practice architectures
trade width `W` against depth `L`. Conjecture: near `λc` there is a conserved
quantity `W^a · L^b ~ |λ - λc|^{-ν}` so that for fixed target error the feasible
`(W, L)` pairs lie on a hyperbola whose position diverges with the same exponent
`ν` derived here, independent of how the budget is split. **The key insight is**
that a degree-`n` polynomial of the operator can be realized either by `n`
sequential applications (depth) or by a width-`n` parallel Krylov basis, so the
*product* — not either factor alone — is what the spectral gap forces to diverge.
**Why now?** The `Nmin` count is exactly the polynomial degree, the invariant
both realizations share; formalizing the two realizations as bounds on `W·L`
turns the heuristic "expressivity = degree" into a theorem, falsifiable by an
architecture that beats the hyperbola at fixed error.

### 5. Non-self-adjoint exceptional points give a strictly larger exponent

For *defective* (Jordan-block / exceptional-point) operators the resolvent norm
blows up faster than `1/g` because of nilpotent coupling between coalescing modes.
Conjecture: for a size-`m` Jordan block whose eigenvalue approaches the spectrum
edge as `D^α`, the minimal solver size diverges as `D^{-α·m}` — the exponent is
multiplied by the Jordan size, a strictly different universality class from the
diagonalizable (`m = 1`) case. **The key insight is** that
`‖(A - z)^{-1}‖ ∼ g^{-m}` for an `m`-fold defective eigenvalue, so the *effective*
contraction seen by any polynomial solver is `1 - g^{m}` rather than `1 - g`,
feeding straight into our sandwich with exponent `α·m`. **Why now?** The model
needs only a scalar effective-gap input, which `Core.lean` already isolates, so
the conjecture is testable by instantiating the sandwich with `g^m` and is
falsifiable by any defective family whose measured exponent stays at `α`,
independent of Jordan size.

**Novelty estimate**: 0.75
**Breakthrough potential**: 0.75
Research domain: Novelty
Research mode: team




### Recent Discoveries in Catalog
No previous research cycles completed yet. This is a cold start — prioritize sorry_fill on the priority targets (CarmichaelComposite, Fib_gcd_identity) to close known open problems, or target cross-domain bridge theorems for novelty.


## v14 Depth Requirements -- Conceptual Unifier: Local-to-Global Sheaves Research Engine

You are leading a mathematical research team. Your goal is to produce groundbreaking,
master-class, useful, novel, and marvelous new Mathematics that pushes the frontier of human knowledge.

This engine is configured for **Conceptual Unification (Local-to-Global Sheaves)**. Explore sheaf theory, local-to-global translations, and cohomological obstructions.

### RESEARCH CORE METHODOLOGY:
1. **Local-to-Global Translation**: Construct sheaves or presheaves to describe local properties that glue together to form global structures. Check if local solutions can be extended globally.
2. **Obstruction Theory & Cohomology**: Use cohomology groups or obstruction classes to mathematically measure the failure or boundaries of local-to-global extensions.
3. **Stalk-Level Reduction**: Reduce complex global proofs to stalk-level computations or local neighborhood verifications, using algebraic localization or geometric limits.

### DELIVERABLES:
- **Lean 4 proofs** of deep, non-trivial theorems with complete proofs (no sorry on main results).
- **Lab Notebook** comment blocks in each .lean file detailing Hypothesis, Result, Insight, and Failure analysis.
- **FUTURE_DIRECTIONS.md** outlining the Synthesis of your findings, a Results Summary, and 3-5 bold, falsifiable research directions to steer the next cycle.


## Output format reminder

Your output must include `.lean` files AND a `FUTURE_DIRECTIONS.md` file.
The .lean files contain the proofs. The FUTURE_DIRECTIONS.md contains 3-5
research conjectures that extend the work. Both are required.
Be precise, be deep, be world-class.
