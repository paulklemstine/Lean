# Future Directions — Universal Scaling of Minimal PDE-Solver Size at a Spectral Phase Transition

## Synthesis

`Core.lean` distills the empirical, ML-flavored conjecture *"minimal
neural-operator size diverges as a universal power law near an operator-spectrum
phase transition"* into a fully formal, machine-checked core. The central object
is the **minimal iteration / depth count** `Nmin ρ ε = least n with ρ^n ≤ ε`, the
scalar shadow of how many Neumann / power-iteration terms (equivalently, how much
polynomial depth) a solver needs to invert a discretized solution operator with
contraction factor `ρ = 1 - g`, where `g` is the spectral gap.

The headline theorem `Nmin_sandwich` proves a **two-sided power law**

```
(1 - ε)/g  ≤  Nmin (1-g) ε  ≤  log(1/ε)/g + 1 ,
```

so the size diverges as `g⁻¹` with a class-universal exponent and an
`ε`-dependent prefactor band `[1-ε, log(1/ε)]`. The entire "critical exponent"
content collapses onto two elementary inequalities — Bernoulli
`1 - n·g ≤ (1-g)^n` (which *forces* divergence) and `1 - g ≤ e^{-g}` (which
*controls* it). This separation is the engine behind every corollary:

* `Nmin_sandwich_accelerated` — feeding the square-root contraction `1 - √g`
  (Chebyshev / conjugate-gradient acceleration) halves the exponent to `1/2`.
* `power_law_control` / `power_law_control_accelerated` — composing with a gap
  `g = D^α` closing as a power of the control parameter `D = |λ - λc|` yields
  divergence `D^{-α}` (unaccelerated) versus `D^{-α/2}` (accelerated).
* `accelerated_exponent_lt` — the two universality classes are genuinely
  distinguished: `α/2 < α`.
* `power_law_discretization_independent` — replacing `g` by `c·D^α` for any
  microscopic discretization constant `c ∈ (0,1]` leaves the exponent equal to
  `α`; only the prefactor moves (renormalization-style universality).

The computable rational analogue `NminQ` makes divergence concrete: as the gap
shrinks tenfold (`ρ = 0.9 → 0.99`) the count grows tenfold (`44 → 459`, both
`#eval`-confirmed), numerically validating the `g⁻¹` law.

## Results Summary

| Theorem | Statement | Exponent ν |
|---|---|---|
| `Nmin_sandwich` | `(1-ε)/g ≤ Nmin (1-g) ε ≤ log(1/ε)/g + 1` | 1 (in `g`) |
| `Nmin_sandwich_accelerated` | same with `g ↦ √g` | 1/2 (in `g`) |
| `power_law_control` | `Nmin ~ D^{-α}` for `g = D^α` | `α` |
| `power_law_control_accelerated` | `Nmin ~ D^{-α/2}` | `α/2` |
| `accelerated_exponent_lt` | `α/2 < α` | — |
| `power_law_discretization_independent` | `g = c·D^α ⇒` exponent `= α` | `α` (∀ `c`) |

All proofs are `sorry`-free and depend only on the standard axioms
`propext`, `Classical.choice`, `Quot.sound`.

## Research Directions

### 1. Logarithmic correction at the exact critical point (a sharper ceiling)

The current bounds pin the exponent but leave a constant-factor gap of
`log(1/ε)/(1-ε)` in the prefactor. **Conjecture:** there is a sharp asymptotic
`Nmin (1-g) ε = log(1/ε)/g · (1 + o(1))` as `g → 0⁺` with `ε` fixed, the
next-order term a pure logarithmic correction independent of `g`. **The key
insight is** that `-1/log(1-g) = 1/g · (1 - g/2 + o(g))`, so the gap between the
two sandwich bounds is itself governed by a convergent power series in `g`,
forcing the prefactor band to collapse to a single value in the limit. **Why
now?** Both one-sided bounds are already formalized; upgrading to a genuine
`Filter.Tendsto` / `Asymptotics.IsEquivalent` statement only needs the
`Real.log (1 - g)` expansion already in Mathlib. Falsifiable by exhibiting any
`ε` for which `Nmin·g / log(1/ε)` fails to converge to 1.

### 2. The square-root acceleration barrier is optimal (a cross-scheme lower bound)

We proved acceleration halves the exponent, but not that `1/2` is the best
possible exponent for any polynomial scheme. **Conjecture:** among all
contraction families `ρ(g)` realizable by degree-`d` polynomial solvers of a
self-adjoint operator with gap `g`, none achieves exponent below `1/2`; i.e.
`Nmin ≥ c·g^{-1/2}` uniformly. **The key insight is** that the Chebyshev
polynomials are extremal for `min_p max_{x∈[g,1]} |1 - x·p(x)|`, so `g^{-1/2}` is a
hard floor from approximation theory, not an artifact of the `1 - √g` model.
**Why now?** Mathlib's Chebyshev library plus the `Nmin` skeleton make the
extremality argument self-contained. Falsifiable by constructing a polynomial
family with provably smaller asymptotic degree.

### 3. Exponent additivity under composed (tensor) phase transitions

Multiphysics solvers face several gaps closing at once. Model this by the product
contraction `ρ = (1 - g₁)(1 - g₂)` with `g₁ = D^{α₁}`, `g₂ = D^{α₂}`.
**Conjecture:** the composed exponent is `ν = max(α₁, α₂)`, *not* `α₁ + α₂` — the
slowest-closing gap dominates, like a rate-limiting step. **The key insight is**
that `1 - (1-g₁)(1-g₂) = g₁ + g₂ - g₁g₂ ≈ g₁ + g₂`, whose power-law exponent near
`D → 0` is set by the larger of `α₁, α₂`. **Why now?** `Nmin_sandwich` already
accepts an arbitrary effective gap, so the result reduces to an elementary
`D^{α₁} + D^{α₂} ≍ D^{min(α₁,α₂)}` estimate. Falsifiable by any coupled model
whose measured exponent exceeds `max(α₁, α₂)`.

### 4. Width–depth tradeoff: a conserved product near criticality

We modeled solver size as a single depth-like count; architectures trade width
`W` against depth `L`. **Conjecture:** near `λc` there is a conserved quantity
`W^a · L^b ~ |λ - λc|^{-ν}`, so the feasible `(W, L)` pairs at fixed target error
lie on a hyperbola diverging with the same exponent `ν`, independent of how the
budget is split. **The key insight is** that a degree-`n` operator polynomial can
be realized as `n` sequential applications (depth) *or* a width-`n` parallel
Krylov basis, so the *product* — not either factor — is what the gap forces to
diverge. **Why now?** The `Nmin` count is exactly the polynomial degree, the
invariant both realizations share; formalizing the two realizations as bounds on
`W·L` turns "expressivity = degree" into a theorem. Falsifiable by an
architecture that beats the hyperbola at fixed error.

### 5. Non-self-adjoint exceptional points give a strictly larger exponent

For defective (Jordan-block / exceptional-point) operators the resolvent norm
blows up faster than `1/g`. **Conjecture:** for a size-`m` Jordan block whose
eigenvalue approaches the spectrum edge as `D^α`, the minimal solver size
diverges as `D^{-α·m}` — the exponent is multiplied by the Jordan size, a
strictly different universality class from the diagonalizable (`m = 1`) case.
**The key insight is** that `‖(A - z)^{-1}‖ ∼ g^{-m}` for an `m`-fold defective
eigenvalue, so the *effective* contraction seen by any polynomial solver is
`1 - g^{m}`, feeding straight into `Nmin_sandwich` with exponent `α·m`. **Why
now?** The model needs only a scalar effective-gap input, which `Core.lean`
already isolates, so the conjecture is testable by instantiating the sandwich at
`g^m`. Falsifiable by any defective family whose measured exponent stays at `α`,
independent of Jordan size.
