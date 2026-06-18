# Future Directions: Descent Basin Theory

## Synthesis

This cycle was a cold start on Descent Basin Theory. The catalog contained no
`DescentSystem` or basin infrastructure, so we built the theory from scratch and proved
the central result the concept was named for: the **Basin Fixed Point Theorem**. The
key structural object is a finite `DescentSystem` — a deterministic update `step` with a
`ℕ`-valued Lyapunov function `energy` that is non-increasing and strictly decreasing off
fixed points. From this we defined the `limit` map (iterate `step` for `energy x + 1`
steps) and showed it lands every state on a fixed point. The decisive engineering choice
was the *additive* step-budget invariant `energy(stepⁿ x) + n ≤ energy x`: it linearises
the strict-descent axiom and avoids the truncating-subtraction pitfalls of `ℕ`. With
`limit` in hand, the Basin Fixed Point Theorem became almost syntactic — the image of
`limit` is exactly the fixed-point set, so basin count equals fixed-point count.

Two structural insights emerged that drive the directions below. First, the reached
fixed point is *unique* (`reach_unique`): once an orbit hits a fixed point it stays,
so all fixed iterates of a state agree. This uniqueness is what makes `limit` well
defined and constant along orbits (`limit_step`), and it is the discrete shadow of the
convergence guarantees one wants in the continuous (Łojasiewicz) setting. Second,
basin counting is *functorial* in two directions: it is multiplicative across
independent subsystems (`prod_fixedPoint_card`) and equivariant under landscape
symmetries (`limit_equivariant`). Multiplicativity is the classical (q → 0) limit of a
conjectural quantum deformation, and equivariance is exactly the input Burnside's lemma
needs to count basins modulo symmetry.

Nothing was disproved this cycle; every declared theorem closed with only the standard
axioms (`propext`, `Classical.choice`, `Quot.sound`). The main friction was definitional:
an early attempt to define `limit` via `Nat.find` of the first fixed time was harder to
compute with than the explicit `energy x + 1` iterate, and the product's strict-descent
field required casing on which coordinate actually moved (a naive `add_lt_add` fails when
only one coordinate changes).

## Results Summary

- `DescentSystem.invariant`: proved — the additive step-budget invariant that linearises strict descent; the engine behind termination.
- `DescentSystem.limit_isFixed`: proved — every orbit reaches a fixed point within `energy x + 1` steps (finite-time convergence).
- `DescentSystem.reach_unique`: proved — the fixed point reached by an orbit is unique; well-definedness of `limit`.
- `DescentSystem.limit_of_fixed`: proved — fixed points are their own limits (surjectivity of `limit` onto the fixed set).
- `DescentSystem.limit_step`: proved — `limit` is constant along orbits; basins are forward-invariant.
- `DescentSystem.image_limit_eq_fixedPoints`: proved — **Basin Fixed Point Theorem**: attained limits = fixed points.
- `DescentSystem.basin_card_eq_fixedPoint_card`: proved — basin count = fixed-point count.
- `DescentSystem.prod_fixedPoint_card`: proved — basin counts are multiplicative across independent subsystems.
- `DescentSystem.limit_equivariant`: proved — landscape symmetries commute with `limit` and permute basins.

## Research Directions

### Direction 1: Equivariant basin counting via Burnside's lemma
**Hypothesis**: For a finite group `G` acting on `X` by symmetries that commute with
`step` and preserve `energy`, the number of basins modulo symmetry equals
`(1/|G|) Σ_{g ∈ G} |Fix(g) ∩ FixedPoints|`, the Burnside average of symmetry-fixed
fixed points.
**Test**: Lift `limit_equivariant` to a `MulAction G X` whose generators each satisfy
the commutation+energy hypotheses, prove the action descends to an action on the
fixed-point Finset, and apply Mathlib's `MulAction.sum_card_fixedBy_eq_card_orbits`.
Validate on an explicit small landscape (e.g. `X = Fin n` with a cyclic symmetry).
**Why now**: `limit_equivariant` already gives the per-symmetry commutation, and
`image_limit_eq_fixedPoints` identifies basins with fixed points, so the only missing
piece is packaging single symmetries into a group action.
**If true**: A purely algebraic formula for the number of *essentially different*
minima found by gradient descent on a symmetric loss (e.g. neuron-permutation symmetry).
**If false**: It would reveal that symmetry-fixed fixed points and symmetry-fixed basins
diverge — i.e. a basin can be setwise fixed without containing a symmetric minimum.

### Direction 2: Quantum deformation of the product formula
**Hypothesis**: Define a `q`-weighted basin number `Q(q) = Σ_paths q^{length}` counting
gradient-flow paths into each fixed point. Then `Q` is multiplicative across independent
subsystems — `Q_{D×E}(q) = Q_D(q) · Q_E(q)` — generalising `prod_fixedPoint_card`
(the `q → 0` / length-0 limit).
**Test**: Formalise path length as the first hitting time `Nat.find` of `limit`, define
`Q` as a `Polynomial ℕ` or `Finset.sum` of `q ^ (hitting time)`, and prove
multiplicativity by the bijection between product paths and pairs of factor paths.
**Why now**: `prod_fixedPoint_card` already supplies the classical multiplicativity and
the componentwise fixed-point bijection that the weighted version refines; hitting time
is definable from the `invariant` budget.
**If true**: A first rigorous toehold on the conjectural Gromov–Witten/WDVV analogy for
basin structure.
**If false**: The failure mode (paths that merge before reaching the fixed point) would
pinpoint exactly why naive path-counting is not a ring homomorphism.

### Direction 3: Quotient descent systems and basin coarse-graining
**Hypothesis**: If `~` is a `step`- and `energy`-compatible equivalence on `X`, then the
quotient inherits a `DescentSystem` structure and the quotient map sends basins onto
basins surjectively, with `#basins(X/~) ≤ #basins(X)`.
**Test**: Define the quotient `step`/`energy` via `Quotient.lift`, discharge the descent
axioms from the representatives, and prove a `limit`-naturality square
`limit ∘ π = π ∘ limit`. Bound the basin counts with `Finset.card_image_le`.
**Why now**: `limit_equivariant` is exactly the special case where `~` is the orbit
relation of a single symmetry; generalising the commutation argument from a bijection to
a quotient map is a small structural step.
**If true**: A clean coarse-graining/renormalisation operation on descent landscapes,
matching how pooling/weight-tying reduces effective parameter counts in networks.
**If false**: It would show that quotienting can *create* spurious basins, constraining
which symmetries are safe to mod out.

### Direction 4: Sharp termination bound and discrete Morse refinement
**Hypothesis**: The reach time satisfies `hitting(x) ≤ energy x` (not just `energy x + 1`),
and more refined: the number of *strict* descent steps equals `energy x − energy(limit x)`
when `energy` decreases by exactly one per non-fixed step.
**Test**: Strengthen `invariant` to track equality on the non-fixed segment, then prove
the tight bound; as a corollary, count critical cells by stratifying states by
`energy x − energy(limit x)` and check the alternating sum against an Euler
characteristic on a small simplicial example.
**Why now**: The `invariant` already gives the `+1`-slack bound; tightening it is a local
edit, and the energy-difference stratification is the combinatorial input the weak Morse
inequality needs.
**If true**: Connects basin theory to Forman's discrete Morse theory, giving Betti-number
lower bounds on critical-cell counts.
**If false**: The gap between `energy x` and the true hitting time would expose
landscapes where energy over-counts descent steps (plateaus), which is itself the
interesting Morse-theoretic phenomenon.

### Direction 5: Continuous basins via Łojasiewicz gradient flows
**Hypothesis**: For a real-analytic `L : ℝⁿ → ℝ` satisfying a Łojasiewicz inequality
`‖∇L(θ)‖² ≥ c·|L(θ) − L(θ*)|^α` near each critical point, the gradient flow has finite
trajectory length and a well-defined `limit` map, and the continuous Basin Fixed Point
Theorem holds: the image of `limit` is the critical set.
**Test**: State the Łojasiewicz inequality and finite-length lemma in Mathlib's analysis
framework, mirror the discrete proof skeleton (budget invariant → bounded length → Cauchy
→ convergence) with energy replaced by `L` and the step budget by trajectory arc length.
**Why now**: The discrete proof here is structured exactly as
`invariant → limit_isFixed → reach_unique → image_limit_eq_fixedPoints`, and each step
has a direct continuous analogue once finite length is available; Mathlib supplies the
metric-space and ODE foundations.
**If true**: Extends the theorem to the setting of actual neural-network training
(parameters in `ℝⁿ`).
**If false**: The breakdown (e.g. infinite-length spiralling orbits without Łojasiewicz)
would precisely delimit when discrete intuition transfers to continuous gradient flow.
