# Computational Evidence — Galerkin Navier–Stokes Energy Method

This note records the small-case checks performed before formalizing the
theorems in `EnergyMethod.lean` and `Bridge.lean`.

## 1. The trilinear cancellation is the load-bearing fact

The abstract model is `u'(t) = -(ν A u) - B(u,u)` with the two hypotheses

* `A` positive semidefinite: `⟪A v, v⟫ ≥ 0`,
* `B` energy-preserving: `⟪B v v, v⟫ = 0`.

Differentiating `E(t) = ‖u‖²` gives, by the product rule,
`E'(t) = 2⟪u', u⟫ = 2(-ν⟪A u, u⟫ - ⟪B(u,u), u⟫) = -2ν⟪A u, u⟫ ≤ 0`.

**Concrete 2D check of cancellation.** Take `V = ℝ²` and the rotation-type
nonlinearity `B(u,u) = (u₁u₂, -u₁²)`. Then
`⟪B(u,u), u⟫ = u₁u₂·u₁ + (-u₁²)·u₂ = u₁²u₂ - u₁²u₂ = 0` for every `u`. So an
energy-preserving quadratic nonlinearity genuinely exists; the hypothesis `hB`
is satisfiable and the `Model` structure is inhabited (non-vacuous).

**Counterexample hunt (why `hB` cannot be dropped).** With
`B(u,u) = (u₁², 0)` we get `⟪B(u,u), u⟫ = u₁³`, which is positive for `u₁ > 0`.
Then `E'(t) = -2ν⟪A u, u⟫ + 2u₁³` can be made positive (e.g. `ν` small,
`A = 0`), so energy is NOT monotone. This confirms the cancellation is
necessary, not decorative — matching the analysis note that the genuine 3D
difficulty lives in the *higher* norms that cancellation does not control.

## 2. Tropical side: the energy is a nonincreasing sequence

For the max-plus operator `tropDiffMax K u i = sup_j (u j - K i j)` with
`K ≥ 0`, `K i i = 0`, a hand computation on `ι = {0,1}`,
`u = (0, 1)`, `K = [[0, 1],[1, 0]]`:

* `tropDiffMax K u 0 = max(u₀-0, u₁-1) = max(0,0) = 0`
* `tropDiffMax K u 1 = max(u₀-1, u₁-0) = max(-1,1) = 1`

so `tropEnergy = sup = 1` before and after one step: nonincreasing (here
constant). Iterating keeps `sup ≤ 1`. This matches `tropEnergy_iterate_antitone`
(the sequence of suprema is antitone) and the catalog bound `iterate_sup_bound`.

## 3. Scope statement

These are dimensional / structural sanity checks, deliberately small. No OEIS
sequence arises (the objects are analytic inequalities, not integer sequences),
so an OEIS search is not applicable. The checks confirmed that (a) the model is
non-vacuous, (b) the cancellation hypothesis is exactly the boundary between a
true and a false energy estimate, before any Lean proof was attempted.
