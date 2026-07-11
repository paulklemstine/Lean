# Computational Evidence

The claims are exact ordinal-arithmetic identities, so "evidence" takes the form
of checking the survival values and the small-case survivable rounds directly.

## Survival values (order types of the moment sets)

| Game | Moments | Order type (survival value) |
|------|---------|-----------------------------|
| finite deterministic | `ℕ` | `ω` |
| bounded nondeterministic | `ℕ ×ₗ ℕ` (lex) | `ω · ω = ω²` |
| `ω`-refinement of a game `G` | `Lex (G.Moment × ℕ)` | `ω · value(G)` |

These follow from `type_nat_lt` (`type (<) = ω` on `ℕ`) and
`type_prod_lex` (`type (Prod.Lex s r) = type r * type s`).

## Small-case survivable rounds

Finite game — Mortal survives round `n` for every finite `n` because
`(n : Ordinal) < ω`:

```
n = 0, 1, 2, 3, ...   all ≤ ω = value    ⇒  survivable
first non-survivable round = ω
```

Nondeterministic game — Mortal survives round `ω · n` for every finite `n`
because `ω · n ≤ ω · ω = ω²`:

```
ω·0 = 0,  ω·1 = ω,  ω·2,  ω·3, ...   all ≤ ω² = value   ⇒ survivable
first non-survivable round = ω²
```

## Counterexample hunt

The sharpness theorems are the counterexample check in the other direction:
`ω + 1 > ω` and `ω² + 1 > ω²`, so `omega_is_sharp` and `omega_sq_is_sharp`
confirm Mortal *cannot* survive one round beyond the value. No round below the
value fails, and no round at/above it succeeds — the boundary is exact.

All of the above is machine-checked in `Catalog/Novelty/ImmortalityGame.lean`
(`finite_forces_nat`, `nondet_forces_omega_mul_nat`, `omega_is_sharp`,
`omega_sq_is_sharp`), so no separate numerical script is needed.
