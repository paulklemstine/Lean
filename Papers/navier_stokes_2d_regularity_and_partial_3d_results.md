# Computational Evidence

Concise pre-proof checks for the two new results. The objects are analytic, so
the relevant "computation" is exact symbolic verification on the simplest
non-trivial instance, the scalar model on `V = ℝ`.

## 1. Exponential decay is sharp (scalar model)

Take `V = ℝ`, `A = id` (so `⟪A v, v⟫ = v²`, coercive with `λ = 1`), `B = 0`,
viscosity `ν > 0`. The model ODE is `u'(t) = −ν u(t)`, with solution
`u(t) = u₀ e^{−ν t}`.

| quantity | value |
|---|---|
| `E(t) = u(t)²` | `u₀² e^{−2ν t}` |
| bound `E(0) e^{−2νλ t}` (λ=1) | `u₀² e^{−2ν t}` |
| ratio | `1` (bound is attained) |

So `energy_exp_decay` holds with **equality** here: the constant `2νλ` is the
true decay rate, confirming the inequality is not lossy and `λ = 1` is the right
coercivity constant. Numerically (u₀=1, ν=1): E(1)=0.1353, bound=0.1353;
E(2)=0.0183, bound=0.0183.

## 2. Uniqueness hypothesis is satisfiable, conclusion non-vacuous

With `B = 0` the Ladyzhenskaya bound `−⟪B(u,u)−B(w,w),d⟫ ≤ C‖d‖²` holds with
`C = 0`. Two solutions `u, w` of `u' = −ν u` with `u(t₀) = w(t₀)` give difference
energy `E_d(t) = (u(t₀)−w(t₀))² e^{−2ν(t−t₀)} = 0`, so `u ≡ w`. This matches
`eq_of_energy_estimate` and shows the hypotheses are simultaneously satisfiable
on a genuine (non-constant) trajectory, so the theorem is not vacuous.

## 3. Counterexample hunt (forward vs backward)

Running the scalar model *backward* from `t₀` with `C > 0`: the inequality
`E_d' ≤ 2C E_d` does not constrain `E_d` for `t < t₀`. Concretely, a hypothetical
`E_d(t) = ε e^{2C(t−t₀)}` satisfies `E_d' = 2C E_d` and `E_d(t₀) = ε`; sending
`ε → 0` shows nothing forces `E_d = 0` for `t < t₀`. This confirms the proof must
restrict to `t ≥ t₀` (it does) and motivates Conjecture 1 in FUTURE_DIRECTIONS.

## Conclusion

The computational landscape supports both theorems: the decay bound is tight
(equality on the bottom eigenmode) and the uniqueness hypotheses are satisfiable
with non-trivial dynamics. No counterexample to the *forward* statements was
found; the only failure mode (backward uniqueness) is correctly excluded by the
`t₀ ≤ t` hypothesis.
