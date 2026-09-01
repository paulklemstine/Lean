# Computational evidence — NET-66 one-octave shift law

All numbers below were produced by `#eval` inside the Lean project (Lean 4.28.0 /
Mathlib), against the definitions that the theorems use, so the tables and the proofs
speak about the same objects.  Each item is followed by the theorem that turns the
observation into a proof.

## 1. The two measured chains and the shift

Measured knees `k*` at gate `0.98` (contexts `512, 1024, 2048`, i.e. octaves `0,1,2`):

| octave `j` | ctx  | 0.5B (`s=0`) | 1.5B (`s=1`) |
|-----------:|-----:|-------------:|-------------:|
| 0          |  512 | 16           | 16           |
| 1          | 1024 | 20           | 16           |
| 2          | 2048 | 24           | 20           |

`#eval (List.range 4).map (fun j => (shift net66Base 0 j, shift net66Base 1 j, shift net66Base 2 j))`

```
[(16, 16, 16), (20, 16, 16), (24, 20, 16), (28, 24, 20)]
```

Column `s=1` is column `s=0` shifted down by one row: the one-octave law on the nose
(`net66_one_octave`, `ScaleFamily.eq_shift`).  Column `s=2` is the prediction for the
next scale step (`net66_predict_7B`).

## 2. First failing octave (budget table)

For budgets `16, 20, 24, 28` and scales `0, 1, 2`, the least octave whose knee exceeds
the budget:

```
scale 0: [1, 2, 3, 4]
scale 1: [2, 3, 4, 5]
scale 2: [3, 4, 5, 6]
```

Every row is the previous row `+1`: one extra context doubling per scale doubling, at
*every* budget.  Proved as `firstFail_shift` / `ScaleFamily.budget_table`; the `16`-key
column is `net66_budget_16` (`1` at 0.5B, `2` at 1.5B) and `net66_delay_one_doubling`.

## 3. Area of the served region (staircase count)

Number of served `(scale, octave)` cells in the `S × 8` corner at budget `16`:

```
S       = 0, 1, 2, 3, 4
measured= 0, 1, 3, 6, 10
S*f + S(S-1)/2 (f = 1) = 0, 1, 3, 6, 10
```

Triangular numbers — OEIS A000217 (`0, 1, 3, 6, 10, 15, …`).  Proved (division-free) as
`ScaleFamily.served_card_two_mul`.

## 4. The measured 2048 row and the razor

Retained values ×10⁴ of the first `ctx = 2048` cell at 1.5B, as reproduced by the step
function `measNum` used in the proofs, and by the cumulative counts `cum` of the
10000-window demand profile `net66Row`:

```
k        :   8     12     16     19     20     24     32     40
measNum  : 9597   9715   9785   9785   9817   9846   9867    —
cum      : 9597   9715   9785    —     9817   9846   9867  10000
```

Gate `0.98 = 9800/10⁴`.  The `k = 16` cell misses by `15/10⁴ ≈ 1 SE`; `k = 20` passes.
Hence the reported knee `20` (`measCurve_knee`, `net66Row_knee`).

Counterexample hunt for the razor: is `20` *identified* by these six numbers?  No.
Bumping the curve upward from any `t ∈ {17,18,19,20}` leaves all six grid readings
unchanged while moving the knee to `t`; bumping from `t = 16` by `15/10⁴` moves it to
`16`.  A spot check that the bumped curve does change the off-grid value at `k = 16`
only when `t ≤ 16`:

```
#eval (List.range 6).map (fun m => bump (16+m) 9817 16)  ⟹  [9817, 9785, 9785, 9785, 9785, 9785]
```

Proved as `razor_bracket_exact` (the consistent knee set is exactly `(16, 20]`) and
`razor_one_se_reopens` (a one-SE perturbation reaches `16`).

## 5. Noise level versus rate identifiability

The base chain rises by `δ = 4` keys per octave.  A shift by `r ≠ 1` differs from the
true one by at least `4` keys somewhere, so any per-cell knee error `ε ≤ 3` still
identifies the rate; only `ε ≥ 4` could confuse a one-octave shift with a two-octave
one.  Proved as `rate_unique_of_noise` and `net66_rate_robust`.

## 6. Sequences

* Served-area sequence: `0, 1, 3, 6, 10, 15, …` — triangular numbers, **OEIS A000217**.
* Knee chain of the linear base: `16, 20, 24, 28, …` — arithmetic progression with
  common difference `4` (`ScaleFamily.linear_base_shift`).

No counterexample to any statement proved in the Lean files was found; the razor
"counterexamples" of §4 are theorems, not defects — they delimit what the grid can
determine.

## 7. Rate discrimination (integer exchange-rate spectrum)

Predicted 1.5B chain (`s = 1`) at octaves `0,1,2` under a rate-`p` law with the measured
base chain `{16, 20, 24}`:

| rate `p` | 512 | 1024 | 2048 | matches measurement? |
|---------:|----:|-----:|-----:|----------------------|
| 1        | 16  | 16   | 20   | yes                  |
| 2        | 16  | 16   | 16   | no (`20` measured)   |
| 3        | 16  | 16   | 16   | no                   |

So one measured cell — `k*(1.5B, 2048) = 20` — excludes every integer rate other than `1`
(`net66_rate_eq_one`, `net66_rate_two_refuted`), and every rate is otherwise consistent
(`ofBase`), so the exclusion is empirical rather than formal.
