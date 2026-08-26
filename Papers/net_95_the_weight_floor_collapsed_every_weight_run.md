# Computational Evidence — NET-95 weight-quantisation ladder

All numbers below are exact rational computations over the measured table
(fp16 control PPL = 6.9825, `llama-perplexity`, ctx = 2048, 8 threads,
250 KB held-out wikitext slice).  Every claim that survives here is
re-proved in Lean; nothing in this file is used as a substitute for a proof.

## 1. Excess perplexity, exactly

`E = PPL − 6.9825`, `relE = E / 6.9825`.

| rung   | tenth-bits | PPL    | E (exact)   | relE        |
|--------|-----------|--------|-------------|-------------|
| q8_0   | 85        | 6.9781 | −11/2500    | −0.0630147% |
| q6_k   | 66        | 7.0006 | 181/10000   | +0.2592195% |
| q5_k_m | 55        | 7.0427 | 301/5000    | +0.8621554% |
| q4_k_m | 48        | 7.1093 | 317/2500    | +1.8159685% |
| q3_k_m | 39        | 7.2758 | 2933/10000  | +4.2005013% |
| q2_k   | 26        | 8.1105 | 141/125     | +16.154672% |

Reproduced by `Catalog/Novelty/WeightQuantFloorLadder.lean`
(`scorecard_P1`, `scorecard_P2_refuted`, `scorecard_P3_refuted`,
`q8_0_within_noise`).

## 2. Per-bit decay rate — the one-parameter fit

For rungs `r` (higher bpw) and `s` (lower bpw), the *per-bit multiplier* is
`m = (E_s / E_r) ^ (1 / Δbpw)`.

Adjacent rungs:

| pair              | Δbpw | E ratio | m      |
|-------------------|------|---------|--------|
| q6_k → q5_k_m     | 1.1  | 3.3260  | 2.9817 |
| q5_k_m → q4_k_m   | 0.7  | 2.1063  | 2.8985 |
| q4_k_m → q3_k_m   | 0.9  | 2.3131  | 2.5390 |
| q3_k_m → q2_k     | 1.3  | 3.8459  | 2.8184 |

The observed band is `m ∈ [2.539, 2.982] ⊂ [5/2, 3]`.  Checking **all ten**
ordered pairs (not only adjacent ones) with exact rational arithmetic:

```
q6_k   q5_k_m  k=11  (5/2)^k ≤ ratio^10 ≤ 3^k   True
q6_k   q4_k_m  k=18  True
q6_k   q3_k_m  k=27  True
q6_k   q2_k    k=40  True
q5_k_m q4_k_m  k=7   True
q5_k_m q3_k_m  k=16  True
q5_k_m q2_k    k=29  True
q4_k_m q3_k_m  k=9   True
q4_k_m q2_k    k=22  True
q3_k_m q2_k    k=13  True
```

(`k` = gap in tenths of a bit; the test is the division-free form
`(5/2)^k · E_r^10 ≤ E_s^10 ≤ 3^k · E_r^10`.)
Formal statement: `weight_ladder_geometric_band`.

Both endpoints of the band are nearly attained (2.539 and 2.982), so neither
`5/2` nor `3` can be tightened by much: the fit is not a loose envelope.

## 3. Convexity check

Secant slopes of `E` against bpw, over all ten triples with increasing bpw,
are strictly increasing — e.g. for (2.6, 3.9, 4.8): −0.0642 < −0.0185; for
(3.9, 5.5, 6.6): −0.01457 < −0.00383.  All ten triples pass.
Formal statement: `weight_ladder_convex`.

## 4. Counterexample hunt

* **Is there a cliff?**  A cliff would be a per-bit factor ≥ 4 (the curvature
  ceiling, `curvatureBound_per_bit`).  Maximum observed over all pairs: 2.982.
  No cliff exists in the measured range — proved as `weight_ladder_cliff_free`.
* **Does the fit break at the bottom rung?**  Predicting `E(2.6)` from
  `E(3.9)` with `m = 2.8` gives 1.112 versus the measured 1.128 (1.4% error),
  the largest deviation over the ladder being ≈9%.  The band statement in §2 is
  the exact-arithmetic version of this observation.
* **Extrapolation:** with the *worst* fitted rate `m = 3`, one further bit below
  q2_k gives `E ≤ 3 × 1.128 = 3.384`, i.e. `relE ≤ 48.46% < 50%`.  So even a
  one-bit extrapolation of the measured law fails to reach the "undeployable"
  threshold (`one_bit_below_q2k_stays_under_fifty_percent`, stated as a
  conditional on the rate persisting).

## 5. Sequence lookups

The rung sequence is measured perplexity data, not an integer sequence; no OEIS
entry applies.  The only structured integer datum is the tenth-bit ladder
`85, 66, 55, 48, 39, 26`, which is a hardware artefact of the llama.cpp k-quant
formats and has no arithmetic content.

## 6. Numbers used in the cycle-2 and cycle-3 files

* Stack composition: `(√0.01816 + √0.0014)² = 0.029645 < 0.03`, so the worst
  case (perfectly aligned perturbations) of q4_k_m weights + K8/V4 cache is
  under 3%; the orthogonal case predicts exactly `1.816% + 0.14% = 1.956%`
  (`cpu_stack_aggregate_bound`, `stack_excess_additive_of_orthogonal`).
* Block scaling: at the k-quant block size `B = 256` the maximal scale gain is
  `√256 = 16 = 2⁴`, i.e. 4 bits; the measured floor shift is
  `6.0 − 2.6 = 3.4` bits, inside the budget
  (`k_quant_block_budget`, `observed_floor_shift_within_block_budget`).
