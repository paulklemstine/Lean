# Computational evidence — NET-78 (THE-INCREMENT-ACCELERATES-AT-4096)

All numbers below were produced by `#eval` inside the project's Lean environment
(against the definitions actually used in the proofs), or are the reported
NET-78 measurements themselves. Every claim that is *proved* is proved in the
three Lean files listed at the end; the tables here are exploration, not
verification.

## 1. The measured input

0.5B, held-out windows, exact gate, `ctx = 4096`:

| k        | 16    | 20    | 24    | 28    | 32    | 40        |
|----------|-------|-------|-------|-------|-------|-----------|
| retained | 0.959 | 0.969 | 0.975 | 0.977 | 0.979 | **0.984** |

Reported knee chain over `ctx = 512, 1024, 2048, 4096` (i.e. `j = 0,1,2,3`
doublings above the base context):

```
k*  = 16, 20, 24, 40      increments  +4, +4, +16
```

Two consequences of the table that the formalisation makes exact:

* the gate `τ` is only known up to `0.979 < τ ≤ 0.984` (it must fail at `k = 32`
  and pass at `k = 40`);
* the grid has a hole between `32` and `40`, so the *true* knee is only known to
  lie in `[33, 40]`, and the increment only in `[9, 16]`.

## 2. Candidate continuations (`#eval` over the fitted laws)

```
j :        0    1    2    3     4      5
ramp  :   16   20   24   40    56     72     -- 16 + 4j + 12(j-2)_+
cubic :   16   20   24   40    80    156     -- Newton interpolant, 16 + 4j + 12·C(j,3)
quad  :   16   20   24   40    92    288     -- 16 + 4j + 4(4^(j-2)_+ - 1)
```

All three agree on the four measured points; they differ already at the next
octave (`56 / 80 / 92`). This is the underdetermination proved in
`fits_underdetermined`.

## 3. Counterexample hunt: the feasibility ceiling

A cache cannot hold more keys than the context has tokens. Comparing each law
with the context length `512·2^j`:

```
j :         512·2^j     quad j     quad j ≤ ctx ?
0            512          16          true
...
10        524288      262196          true
11       1048576     1048632          FALSE   <-- first violation
12       2097152     4194364          FALSE
13       4194304    16777280          FALSE
```

So the geometric continuation is *impossible*, and the violation is not
marginal: it is exponential in the number of further doublings. The formal
statement proved (`kneeQuad_infeasible_at`, `kneeQuad_infeasible`) uses the
safely conservative index `j = m + 12`; the `#eval` above shows the true first
violation is one octave earlier, at `j = 11`.

The ramp and cubic laws violate nothing: `kneeRamp_feasible`,
`kneeCubic_feasible`, and their retained fraction of the context tends to `0`
(`kneeRamp_ratio_tendsto_zero`, `kneeCubic_ratio_tendsto_zero`).

## 4. The grid gap, realised

Two explicit profiles reproduce the *entire* measured table:

```
pLow  : mass 0.959 at index 0, then +0.010 @16, +0.006 @20, +0.002 @24, +0.002 @28, +0.005 @32
pHigh : identical, except the last +0.005 arrives at index 39
```

Both give retention `0.959, 0.969, 0.975, 0.977, 0.979, 0.984` at
`k = 16, 20, 24, 28, 32, 40`. With the admissible gate `τ = 0.98`, the true
knee of `pLow` is `33` and that of `pHigh` is `40` (`bracket_sharp`). Hence the
acceleration factor is only pinned to `[9/4, 4]`, not to `4`.

## 5. Cross-model arithmetic (cycle 3)

1.5B measured chain (NET-67): `16, 16, 18` at `j = 0,1,2`, i.e. the hinge
`max 16 (14+2j)`. Crossing indices of the critical budget of `24` keys:

```
0.5B :  16 + 4j   ≥ 24  first at j = 2   -> ctx = 2048   (= the observed corner)
1.5B :  max 16 (14+2j) ≥ 24  first at j = 5   -> ctx = 16384
```

The coincidence in the first line is what makes the "budget-threshold" reading
of the transition testable: it retrodicts the 0.5B corner and predicts a delay
to `ctx = 16384` for the 1.5B model. The rival "context-threshold" reading
predicts a 1.5B kink already at `ctx = 4096`. The two differ by exactly `8`
keys at `ctx = 4096` (`28` versus `20`) — a single cell decides
(`transfer_experiment_discriminates`).

## 6. OEIS

The chain `16, 20, 24, 40` and its increment sequence `4, 4, 16` are too short
and too model-specific for an OEIS identification to carry information; no
match was pursued. The relevant "sequence" content is instead the fitted
family, whose Newton form `16 + 4·C(j,1) + 0·C(j,2) + 12·C(j,3)` is recorded
explicitly as `kneeCubic`.

## 7. Where the proofs live

* `Catalog/Novelty/AttentionPhaseTransition.lean` — discrete, tropical, gate and
  continuous layers of the NET-78 audit.
* `Catalog/Novelty/AttentionFeasibilityBand.lean` — feasibility ceiling,
  compression limits, discrete Legendre/tropical envelope.
* `Catalog/Novelty/AttentionTransitionTransfer.lean` — crossing indices and the
  two rival transfer laws for the 1.5B model.
