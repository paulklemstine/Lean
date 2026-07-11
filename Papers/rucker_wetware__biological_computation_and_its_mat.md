# Computational Evidence

This project formalizes a *connector* theorem linking **enumerative combinatorics**
(counting hardware configurations) with **asymptotic analysis / information theory**
(the number of bits needed to specify one configuration).

The core comparison is between two disciplines of computing hardware on `n` units:

| Model    | Configurations                     | Count       | Info (bits) `= log₂(count)` |
|----------|------------------------------------|-------------|-----------------------------|
| Wetware  | deterministic maps `Fin n → Fin n` | `n^n`       | `n · log₂ n`  (Θ(n log n))  |
| Silicon  | connection matrices `Fin n → Fin n → Bool` | `2^(n²)` | `n²`          (Θ(n²))       |

## 1. Small-case configuration counts (`n^n` vs `2^(n²)`)

Computed with `#eval` (see `Bridges/WetwareComputation.lean` theorems
`wetware_config_card`, `silicon_config_card`):

```
n :  n^n            2^(n^2)
0 :  1              1
1 :  1              2
2 :  4              16
3 :  27             512
4 :  256            65536
5 :  3125           33554432
6 :  46656          68719476736
7 :  823543         562949953421312
8 :  16777216       18446744073709551616
```

The silicon count grows doubly-exponentially faster, matching `2^(n²) ≫ n^n`.

## 2. Energies (bits) `n·log₂n` vs `n²`

```
n :  n·log₂n     n²
1 :  0.000       1
2 :  2.000       4
3 :  4.755       9
4 :  8.000       16
5 :  11.610      25
6 :  15.510      36
7 :  19.651      49
8 :  24.000      64
```

For every `n ≥ 1` the wetware energy is strictly below the silicon energy
(formalized: `wetware_beats_silicon`).

## 3. Ratio `(n·log₂n)/n² = log₂n / n → 0`

```
n     ratio
2     0.500
4     0.500
8     0.375
16    0.250
64    0.094
256   0.031
1024  0.010
4096  0.003
```

The ratio decreases to `0`, giving computational support for the asymptotic
connector theorem `energy_ratio_tendsto_zero`.

## 4. Counterexample hunt

- `wetware_beats_silicon` claims strictness for all `n ≥ 1`. Checked `n = 1..8`
  above: no counterexample (`n = 0` gives equality `0 = 0`, which is why the
  hypothesis is `1 ≤ n`).
- Eventual periodicity (`orbit_eventually_periodic`) is a pigeonhole fact on any
  finite state space; no finite counterexample can exist.

No counterexamples were found; all computed data is consistent with the formalized
theorems.
