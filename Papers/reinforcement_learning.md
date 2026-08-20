# Computational Evidence — Neurosymbolic RLHF / PPO-ptx objective

All numbers below were produced by floating-point evaluation inside Lean 4
(`Float` arithmetic, `#eval`).  They are *exploratory* evidence only; the
actual verification of every claim is the sorry-free Lean proof in
`Catalog/MachineLearning/RLHF*.lean`.

Fixed test instance (3 responses):

```
ref = (0.20, 0.50, 0.30)      -- SFT reference policy
r1  = (1.0, -0.5, 2.0)        -- reward model A
r2  = (0.3,  0.7, -1.2)       -- reward model B
pre = (0.50, 0.25, 0.25)      -- pre-training distribution
β   = 0.7
```

## 1. Hilbert isometry (`hilbertDist_gibbs`)

| quantity | value |
|---|---|
| `d_H(π_β(r1), π_β(r2))` | 6.285714 |
| `oscil(r1 - r2) / β` | 6.285714 |
| `d_H(π_β(r1), ref)` | 3.571429 |
| `oscil(r1) / β` | 3.571429 |

Exact agreement to floating-point precision: the tilt map is an isometry, not
merely Lipschitz.  (`oscil(r1-r2) = 4.4`, `4.4/0.7 = 6.2857…`.)

## 2. Total-variation bound (`tvDist_le_expm1_hilbertDist`)

| quantity | value |
|---|---|
| `‖π_β(r1) - π_β(r2)‖_TV` | 0.797349 |
| `exp(oscil(r1-r2)/β) - 1` | 535.85 |

| `tanh(d_H/4) = (e^{d/2}-1)/(e^{d/2}+1)` | 0.917253 |

The crude bound holds and is very loose at small `β` (as expected: the exponential
term is the worst case over the whole simplex), but becomes tight as
`oscil(r1-r2)/β → 0`.  The sharp Birkhoff bound `tanh(d_H/4) = 0.917` is
informative on the same instance, and is always below `1` — this is the bound
proved in `RLHFBirkhoffTV.lean` (`tvDist_le_tanh_hilbertDist`).

## 3. Exact PTX regression law (`ptx_at_gibbs`)

| quantity | value |
|---|---|
| `𝔼_pre[log π_β(r1)] - 𝔼_pre[log ref]` | -0.590999 |
| `(𝔼_pre[r1] - F(β,r1)) / β` | -0.590999 |

Identity confirmed.  The sign is negative here, i.e. the aligned model *does*
regress on the pre-training distribution — exactly because
`𝔼_pre[r1] = 0.875 < F(β,r1) = 1.288`, matching `ptx_no_regression_iff`.

## 4. Annealing limits (`tendsto_freeEnergy_zero`, `tendsto_freeEnergy_atTop`)

| β | `F(β, r1)` | predicted limit |
|---|---|---|
| 0.02 | 1.975921 | `max r1 = 2.0` |
| 50.0 | 0.562248 | `𝔼_ref[r1] = 0.55` |

Both limits are approached at the rates proved (`β log(min ref)` and
`(3/4)‖r‖∞²/β = 0.06` at `β = 50`).

## 5. Submodularity of symbolic constraints (`constrainedFreeEnergy_submodular`)

With `S = {0,1}`, `T = {1,2}` and reward `r1`:

| quantity | value |
|---|---|
| `F_S + F_T` | 1.242706 |
| `F_{S∪T} + F_{S∩T}` | 0.303496 |

`F_{S∪T} + F_{S∩T} ≤ F_S + F_T` holds with slack 0.94: relaxing one rule set
helps less once the other has already been relaxed.

## 6. Counterexample hunt

* *Is the TV bound of §2 ever violated?* No violation was found in the sampled
  instances; the proved statement is an inequality, and the sampled slack is
  large.
* *Is the drift budget of `hilbertDist_gibbs_sum_le` an equality?* No — the
  two-round cancellation instance `r, -r` gives drift `0` against a positive
  budget `2·oscil(r)/β`.  This counterexample is itself formalised as
  `drift_cancellation`, so the budget is genuinely an inequality.
* *Does `ptx_no_regression_iff` ever fail without the positivity hypotheses?*
  The identity `ptx_at_gibbs` requires `ref` strictly positive; with a zero
  reference entry the log terms are `Real.log 0 = 0` by convention and the
  identity breaks, which is why full support is assumed throughout.

No OEIS-style integer sequence arises in this problem: all objects are
real-valued functionals of a continuous parameter `β`.
