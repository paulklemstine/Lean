# Computational evidence — fibre spectrum of the orbit–pattern map

All numbers below were produced by `#eval` inside the same Lean 4 / Mathlib environment in which
the theorems are proved, using the definitions of the new files
(`Catalog/Logic/FibreSpectrumRank.lean`, `FibreSpectrumStirling.lean`,
`FibreSpectrumOrderBound.lean`).  They are exploratory data; the *proved* statements are the Lean
theorems named at the end of each section.

## 1. The rank statistic on patterns

`Pattern k` is the type of restricted growth functions `p : Fin k → Fin k` (`p i ≤ i`,
`p ∘ p = p`), the encoding of set partitions of `{0,…,k−1}` used by the catalog.
`rank P = |image P|` is the number of blocks.

For `k = 3` there are `B₃ = 5` patterns; enumerated with their ranks (`P` printed as its list of
values, output of `#eval`):

| pattern | rank | partition |
|---|---|---|
| `[0,0,0]` | 1 | `{0,1,2}` |
| `[0,0,2]` | 2 | `{0,1}{2}` |
| `[0,1,0]` | 2 | `{0,2}{1}` |
| `[0,1,1]` | 2 | `{0}{1,2}` |
| `[0,1,2]` | 3 | `{0}{1}{2}` |

So the rank distribution on `Pattern 3` is `(0,1,3,1)` for `r = 0,1,2,3`.

## 2. The Stirling triangle `stirling k r = #{P : Pattern k | rank P = r}`

```
#eval (List.range 6).map (fun k => (List.range (k+1)).map (fun r => stirling k r))
-- [[1], [0,1], [0,1,1], [0,1,3,1], [0,1,7,6,1], [0,1,15,25,10,1]]
```

These are exactly the rows of **OEIS A008277** (Stirling numbers of the second kind),
`S(4,2) = 7`, `S(5,2) = 15`, `S(5,3) = 25`, `S(5,4) = 10`; the visible recurrence
`S(5,3) = S(4,2) + 3·S(4,3) = 7 + 18 = 25` is *proved in general* as `stirling_succ_succ`, and
`stirling_unique` shows the table is pinned down by that recurrence and its boundary values.

Row sums:

```
#eval (List.range 6).map (fun k => ((List.range (k+1)).map (stirling k)).sum)
-- [1, 1, 2, 5, 15, 52]
#eval (List.range 6).map bell
-- [1, 1, 2, 5, 15, 52]
```

i.e. **OEIS A000110** (Bell numbers).  *Proved*: `bell_eq_sum_stirling`, plus `decide`-checked
row entries in `FibreSpectrumRank.lean`.

## 3. Counterexample hunt for the falling-factorial degeneration

Test of `n^k = Σ_{r ≤ k} S(k,r)·n^{\underline r}` for all `0 ≤ n,k ≤ 4` (pairs
`(n^k, Σ_r S(k,r)·descFactorial n r)`):

```
[[(1,1),(0,0),(0,0),(0,0),(0,0)],
 [(1,1),(1,1),(1,1),(1,1),(1,1)],
 [(1,1),(2,2),(4,4),(8,8),(16,16)],
 [(1,1),(3,3),(9,9),(27,27),(81,81)],
 [(1,1),(4,4),(16,16),(64,64),(256,256)]]
```

No discrepancy in 25 cases (including the degenerate `0^0 = 1`).  *Proved for all `n, k`*:
`pow_eq_sum_stirling_descFactorial`.

## 4. Hand-computed spectra of concrete actions (not machine-verified)

These are pencil-and-paper checks used to sanity-test the shape of the main theorem before
formalising; they are **not** Lean-verified and are recorded only as motivation.

* `G = C₄` acting by rotation on `X = ℤ/4` (regular action, `n = 4`).
  Spectrum `t = (t₀,t₁,t₂,t₃,t₄) = (1,1,3,6,6)` (free action: `t_r = 4^{\underline r}/4` for
  `r ≥ 1`).  Predicted orbit counts `Σ_r S(k,r) t_r`:
  `k=1: 1`, `k=2: 1+3 = 4`, `k=3: 1+3·3+6 = 16`, `k=4: 1+7·3+6·6+6 = 64`,
  matching `4^{k-1}` from Burnside (only the identity has fixed points).
* `G = V₄` (Klein four) acting regularly on 4 points has the **same** spectrum `(1,1,3,6,6)`.
  So the spectrum does not separate `C₄` from `V₄`: it is an invariant of the orbit-count
  sequence only.  This observation is what the rigidity theorems
  `injOrbits_eq_of_card_orbits_eq` / `card_orbits_eq_of_injOrbits_eq` make precise, and it feeds
  Conjecture 1 of `FUTURE_DIRECTIONS.md`.
* Smallest failure of the Bell floor by order: `|G| = 1`, `X = Fin 2`, `k = 2`:
  `|G| = 1 < 2 = 2^{\underline 2}`, so `t₂ ≥ 2` and `#(X²/G) = 4 > 2 = B₂`.  This is the
  hypothesis pattern of `bell_lt_card_orbits_of_card_lt`, so that theorem is not vacuous.
