# Computational Evidence — radix-growth threshold

All numbers below were produced by `#eval` inside Lean 4 (mathlib4 v4.28.0), using the
same recurrences that the formal file `Catalog/Physics/RadixGrowthThreshold.lean` uses:

```lean
def V (r : Nat → Nat) : Nat → Nat
  | 0     => 1
  | k + 1 => r (V r k) * V r k

partial def logStar (n : Nat) : Nat := if 1 < n then 1 + logStar (Nat.log 2 n) else 0

def rh (r) (n) : Nat := least k ≤ 300 with n < V r k     -- bounded search for radixHeight
```

Three schedules are used throughout:

| name | `r x` | regime |
|---|---|---|
| `rExp` | `max 2 (2 ^ x)` | exponential (`2 ^ x ≤ r x`) |
| `rSq`  | `x ^ 2 + 2`     | polynomial (`r x ≤ x ^ 3` for `x ≥ 2`) |
| `rLin` | `x + 2`         | polynomial (`r x ≤ x ^ 2` for `x ≥ 2`) |

## 1. Small-case calculations

`log* n` for `n = 0 … 19`:

```
0 0 1 1 2 2 2 2 2 2 2 2 2 2 2 2 3 3 3 3
```

and `log* 65535 = 3`, `log* 65536 = 4`, `log* (2^64) = 4`, `log* (2^1000) = 4`.

Weights:

* `V rExp k`, `k = 0…4`:  `1, 2, 8, 2048, 6.6·10^619` (already a tower: `V rExp (k+1) = 2^{V k}·V k`).
* `V rSq  k`, `k = 0…7`:  `1, 3, 33, 36003, 4.67·10^13, 1.02·10^41, 1.05·10^123, 1.16·10^369`
  — the exponent triples at each step, i.e. `log V k ≍ 3^k` (doubly exponential in `k`).
* `V rLin k`, `k = 0…9`:  `1, 3, 15, 255, 65535, 4294967295, …` — exactly `2^(2^k) − 1`,
  again doubly exponential (`log V k ≍ 2^k`).

The observed `V rSq k` and `V rLin k` are consistent with the proved bound
`V r k ≤ M ^ (E ^ k)` (`V_le_pow_pow`): only *doubly* exponential in `k`, never towering.

## 2. Sequence identification

No online OEIS lookup was possible (no network access in this environment), so no A-numbers
are claimed. Two of the sequences are classical in closed form and were verified numerically
here: `tower k = 1, 2, 4, 16, 65536, …` (tower of twos) and
`V rLin k = 2^(2^k) − 1 = 1, 3, 15, 255, 65535, 4294967295, …`.

## 3. Divergence hunt: `radixHeight` versus `log*`

For `n = 2^(2^j)`:

| `j` | `n` | `log* n` | `radixHeight rLin n` | `radixHeight rSq n` |
|---|---|---|---|---|
| 0 | 2 | 1 | 1 | 1 |
| 1 | 4 | 2 | 2 | 2 |
| 2 | 16 | 3 | 3 | 2 |
| 3 | 256 | 3 | 4 | 3 |
| 4 | 65536 | 4 | 5 | 4 |
| 5 | 2^32 | 4 | 6 | 4 |
| 6 | 2^64 | 4 | 7 | 5 |
| 8 | 2^256 | 4 | 9 | 6 |
| 10 | 2^1024 | 4 | 11 | 7 |
| 12 | 2^4096 | 4 | 13 | 9 |
| 14 | 2^16384 | 4 | 15 | 10 |

`log*` has saturated at `4` while both polynomial schedules keep growing (`j + 1` for `rLin`,
`≈ log₃ j` — more precisely `≈ log_{3} log₂ log₂ n` — for `rSq`). This is exactly the
separation formalised in `radixHeight_not_bigO_logStar_large`.

For the exponential schedule the two quantities stay locked together:

| `j` | `log* (2^(2^j))` | `radixHeight rExp (2^(2^j))` |
|---|---|---|
| 0 | 1 | 2 |
| 1 | 2 | 2 |
| 2 | 3 | 3 |
| 3 | 3 | 3 |
| 4 | 4 | 4 |
| 5 | 4 | 4 |
| 6 | 4 | 4 |
| 7 | 4 | 4 |

consistent with the proved sandwich `log* n ≤ 2·radixHeight ≤ …` and
`radixHeight ≤ log* n + 1` (`expSchedule_radixHeight_theta`).

## 4. Counterexample hunt

* Monotonicity of the weights (`V r k < V r (k+1)`) was checked for `rSq`, `k = 0…6`: all `true`
  (formally proved as `V_monotone` under `2 ≤ r`).
* We looked for an `n ≤ 2^16384` violating `radixHeight rExp n ≤ log* n + 1` in the sampled
  range above: none found, in agreement with the theorem.
* Caveat, honestly reported: for the *quadratic* schedule the divergence from `O(log* n)` is
  only of size `log log log n` versus `log* n`, so it is invisible in any humanly computable
  range (one needs `n` above a tower of height `≈ log* n`). This is precisely why the formal
  proof, rather than numerics, is the load-bearing evidence here; the linear schedule `rLin`
  is the numerically visible surrogate.

All statements in the Lean file are proved unconditionally; the tables above are exploratory
data, not part of any proof.
