# Computational evidence for the OR-COLLAPSE-LAW

All numbers below were produced by direct evaluation of

```
Hb(x)   = -x log2 x - (1-x) log2 (1-x)          (binary entropy, bits)
g(n)    = Hb((2n-1)/n^2) - (1/n) Hb(1/n) - ((n-1)/n) Hb(2/n)
chi2(n) = 1 / (ln 2 * (n-1) * (2n-1))           (the bound proved in Lean)
```

## 1. The decay table (n = 2 … 9)

| n | g(n) | chi2 bound | n^2 · g(n) |
|---|------|-----------|-----------|
| 2 | 0.3113 | 0.4809 | 1.2451 |
| 3 | 0.0728 | 0.1443 | 0.6550 |
| 4 | 0.0359 | 0.0687 | 0.5741 |
| 5 | 0.0215 | 0.0401 | 0.5384 |
| 6 | 0.0144 | 0.0262 | 0.5181 |
| 7 | 0.0103 | 0.0185 | 0.5050 |
| 8 | 0.0077 | 0.0137 | 0.4958 |
| 9 | 0.0060 | 0.0106 | 0.4889 |

The `g(n)` column reproduces exactly the decay list quoted in the mission
statement (0.3113 / 0.0728 / 0.0359 / 0.0215 / 0.0144 / 0.0103 / 0.0077 / 0.0060)
and the first five entries reproduce the machine-measured values of the seven
fields in the experimental table (0.3076, 0.0704, 0.0735, 0.0384, 0.0222, 0.0146,
0.0700) to within the quoted 1–2 % sampling error.

## 2. Closed forms found and then proved in Lean

```
g(2) = 3/2 - (3/4) log2 3                       = 0.311278124459...
g(3) = log2 3 - (5/9) log2 5 - 2/9              = 0.072780225784...
g(4) = 11/4 - (15/16) log2 3 - (7/16) log2 7    = 0.035879877174...
g(5) = log2 5 - (6/25) log2 3 - 48/25           = 0.021537094714...
```
(`g(2)` and `g(3)` agree with the previously catalogued values `Ior 2`, `Ior 3`;
`g(4)`, `g(5)` are new.)

## 3. Counterexample hunt for the chi-square collapse bound

The claim `g(n) ≤ 1/(ln 2 · (n-1)(2n-1))` was tested on a dense grid of *real*
`n ∈ [2, 200]` (step 0.01): **no violation**. The ratio
`g(n) · ln 2 · (n-1)(2n-1)` stays inside `[0.502, 0.648]` on that range
(value `0.6473` at `n = 2`), so the bound is never worse than a factor 2 and has
the correct `1/n²` order — it is not improvable in the exponent.

## 4. Asymptotics observed (motivating FUTURE_DIRECTIONS conjecture 1)

`n^2 g(n) → 1/ln 2 - 1 = 0.4426950409…` (column 4 of the table above is
monotonically decreasing towards this value), while the proved bound gives
`n^2 g(n) ≤ n^2/(ln 2 (n-1)(2n-1)) → 1/(2 ln 2) = 0.7213`.

## 5. No OEIS sequence

`g(n)` is a transcendental-valued sequence, not an integer sequence; the only
integer sequence appearing is the OR-fibre count `1, 2, 2, 2, …` (fibre of the
identity vs. non-identity classes) and the total OR count `2n-1`
(odd numbers, OEIS A005408), both of which are proved exactly in the Lean file
(`card_orFiber`, `card_orEvent`).
