# Computational evidence — NET-62 grid-quantization round

All numbers below were produced by `#eval` inside the project's Lean environment
(against the same module that carries the theorems), not by an external script.  Each
one is subsequently *proved* in the `.lean` files; the table is the exploration that
fixed the statements.

## 1. Dyadic (doubling-sweep) readings, `k ↦ 2 ^ ⌈log₂ k⌉`

```
k    :  1  2  3  4  5 … 8  9 …16 17 …20 …24 …28 …32
read :  1  2  4  4  8 … 8 16 …16 32 …32 …32 …32 …32
```

Consequences visible immediately:

* `20 ↦ 32` and `24 ↦ 32`: the two disputed cells (the old `ctx = 1024` reading and the
  `ctx = 2048` "corpus-B" reading) are the *same* rounding.  Proved as
  `Net62.coarse_chain_collapse`.
* `16 ↦ 16`: only the `ctx = 512` cell survives a doubling sweep unchanged.
* the whole octave `(16, 32]` is a single verdict — 16 consecutive true knees,
  one reported value.

## 2. Binary weight and divisor count along the chain

| k  | base-2 digit sum | τ(k) = #divisors |
|----|------------------|------------------|
| 12 | 2 | 6 |
| 16 | 1 | 5 |
| 20 | 2 | 6 |
| 24 | 2 | 8 |
| 28 | 3 | 6 |
| 32 | 1 | 6 |

* digit sum `= 1` ⟺ dyadically resolvable (`GridKnee.dyad_exact_iff_binary_weight_one`);
  only `16` and `32` qualify, so `20` and `24` *cannot* be read correctly by a doubling
  sweep, whatever the model.
* τ counts the arithmetic sweeps that resolve `k`
  (`GridKnee.arith_resolves_iff_mem_divisors`).  τ is not monotone: `τ(24) = 8 > τ(28) = 6`
  though `24 < 28` — proved as `GridKnee.resolution_power_not_monotone`.

## 3. Resolvable budgets in `(0, N]`: doubling vs. step-4

| N | doubling sweep (`log₂N + 1`) | step-4 sweep (`N/4`) |
|---|------|------|
| 16 | 5 | 4 |
| 32 | 6 | 8 |
| 64 | 7 | 16 |
| 128 | 8 | 32 |
| 256 | 9 | 64 |
| 1024 | 11 | 256 |

The crossover is at `N = 32`, matching the proved threshold `m ≥ 5` in
`GridKnee.dyad_loses_to_fine_grid`.  The `clog₂N + 1` verdict bound
(`GridKnee.card_verdicts_dyad_le`) takes the same values in this range: over budgets up
to `1024` a doubling sweep has at most **11** distinct verdicts available.

## 4. Counterexample hunt

The claim under test was: *the fine sweep `{4, 8, 12, 20, 24}` shows the knee is `20`.*
Searching monotone step profiles that reproduce all five measured values, the crossing
point is free anywhere in `(12, 20]` because the grid contains no point in `(12, 20)`.
Two explicit witnesses (`Net62.profileLo`, jump at `16`; `Net62.profileHi`, jump at `20`)
give the same reading `20` and different true knees — this is the counterexample to the
strengthened reading, and it is formalised as `Net62.knee_underdetermined`.  The
unstrengthened, deployment-facing reading (`20` keys suffice; the knee is `> 12`) is
proved as `Net62.measured_knee_eq_twenty` and `Net62.true_knee_bracket`.

## 5. OEIS

The two grids are A000079 (powers of two, `1, 2, 4, 8, 16, 32, …`) and A008586
(multiples of four, `0, 4, 8, 12, 16, 20, 24, …`).  The dyadic reading `2 ^ ⌈log₂ n⌉` is
A062383-adjacent (`A053644`/`A062383` are the neighbouring "highest/next power of 2"
sequences); no new sequence is claimed here.
