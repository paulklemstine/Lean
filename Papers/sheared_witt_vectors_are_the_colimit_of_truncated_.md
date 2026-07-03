# Computational Evidence: Sheared vectors as the colimit of truncated vectors

This note records the small-case checks performed before formalization, for the
claim that the *sheared* (finite-essential-support) coordinate functor is the
filtered colimit of the *truncated* (finite-arity) functors, both in the
arity variable and, fused, in the base-ring variable.

## 1. The shearing mechanism (arity direction)

Model a truncated object at level `n` as the sequences `g : ℕ → A` that are equal
to a fixed basepoint `b` beyond coordinate `n`:

```
T_n = { g : ℕ → A | ∀ k, n ≤ k → g k = b }.
```

These form an increasing chain `T_0 ⊆ T_1 ⊆ T_2 ⊆ …` (padding a level-`n`
sequence with `b` embeds it at level `n+1`). Small cases with `A = ℕ`, `b = 0`:

| `g`                     | smallest `n` with `g ∈ T_n` |
|-------------------------|-----------------------------|
| `0,0,0,0,…`             | 0                           |
| `5,0,0,0,…`             | 1                           |
| `5,3,0,0,…`             | 2                           |
| `5,3,7,0,0,…`           | 3                           |
| `1,1,1,1,…` (identity)  | none (not finitely supported) |

Directed union `⋃ₙ T_n` = exactly the finitely-supported sequences
`{ g | ∃ N, ∀ k ≥ N, g k = b }` (the sheared object). The identity-like
`k ↦ k` is *not* captured — as expected, it has infinite support. This is the
content of `iUnion_trunc_eq_sheared`.

## 2. Base-ring direction fused with arity (the full statement)

Take `R = MvPolynomial ℕ K` with the variable-support filtration
`S_i = { p | p.vars ⊆ {0,…,i} }`. This is a monotone directed family of subrings
with `⨆ᵢ S_i = R`. A finitely-supported coordinate sequence over `R`, say

```
g = (X 0, X 0 * X 2, 0, 0, …),
```

has support `≤ 3` (level `n = 3`) and all entries in `S_2` (all variables `≤ 2`),
so it appears at the single stage `(i, n) = (2, 3)` of the double union
`⋃ᵢ ⋃ₙ { g | (g truncated at n) ∧ (entries in Sᵢ) }`. Every finitely-supported
sequence with entries in the colimit is caught by *some* single `(i, n)`, because
directedness merges the finitely many stages of the finitely many non-`b`
coordinates. This is `sheared_double_colimit`.

## 3. Counterexample hunt (necessity of shearing)

The "vector of all variables" `g = (X 0, X 1, X 2, X 3, …)` over
`MvPolynomial ℕ K` is the decisive counterexample to dropping finite support:

* Every coordinate lifts: `X k ∈ S_k ⊆ ⨆ᵢ Sᵢ`.
* The whole vector lifts to **no** single stage: a lift to stage `i` would force
  `X (i+1) ∈ S_i`, i.e. `{i+1} ⊆ {0,…,i}`, i.e. `i+1 ≤ i`, false.

Checked for `i = 0,1,2,3`: in each case the obstruction is the coordinate
`X (i+1)` whose single variable exceeds the stage bound. This is
`naiveWitt_colimit_fails`, and it certifies that the colimit statement is *false*
without shearing — the sheared repair is genuinely needed, not a convenience.

## 4. Tropical instance

The mechanism is basepoint-agnostic. Over the tropical (min–plus) semiring
`Tropical (WithTop ℕ)` the tropical zero is `0 = trop ∞`, and "finite support"
means "eventually `∞`". Small cases:

| tropical vector           | finitely supported? |
|---------------------------|---------------------|
| `(trop 2, trop 5, ∞, ∞…)` | yes (level 2)       |
| `(trop k)_{k}` growing    | yes only if eventually `∞` |

So the same chain-union identity holds verbatim, giving the Witt ⇄ tropical
bridge `tropical_sheared_eq_colimit_truncated`.

## Conclusion

All small cases are consistent with the four formalized statements; the single
universal claim that could fail — colimit preservation *without* shearing — does
fail, exactly on the natural "all variables" vector, and this failure is itself
formalized.
