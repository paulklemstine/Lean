# Computational evidence — external-hint filters (paper 138)

All closed forms below are *proved* in `Catalog/Novelty/ExternalHintMasterLaw.lean`
and `Catalog/Novelty/ExternalHintGuessingBound.lean`; the tables were computed
with exact rational arithmetic (`#eval` over `ℚ` in Lean) before formalising,
as sanity checks of the formulas.  The exhaustive guessing check (§4) was run
in a Python scratch script and is exploratory only — its general statement is
the Lean theorem `guessing_bound`.

## 1. Certain-hint ladder `L(t) = 2^(t-2)/(1 - 2^(1-t))`

| t | L(t) | L(t+1)/L(t) |
|---|------|-------------|
| 2 | 2 | 4/3 |
| 3 | 8/3 | 12/7 |
| 4 | 32/7 | 28/15 |
| 5 | 128/15 | 60/31 |
| 6 | 512/31 | 124/63 |
| 8 | 8192/127 | 508/255 |
| 10 | 131072/511 | 2044/1023 |

The ratio is `2(2^t-2)/(2^(t+1)-2) → 2` (`ladder_ratio_tendsto`) and
`2^t/L(t) = 4(1-2^(1-t)) → 4` (`ladder_bit_loss_tendsto`): two bits lost.

## 2. Canonical partition law `8/(7-2α)` (`K = 2`, `θ = 1/2`)

| α | 0 | 1/4 | 1/2 | 3/4 | 1 |
|---|---|-----|-----|-----|---|
| speedup | 8/7 | 16/13 | **4/3** | 16/11 | **8/5** |

`α = 1/2` is the uninformative point (= the internal `4/3` cap);
`α = 1` is the which-factor ceiling `8/5 < 2`.

## 3. `r`-factor ceiling `(s+1)K²/(sK² - (s-1)K + s)`, `r = s+1`

| K | r = 2 | r = 3 | r = 4 |
|---|-------|-------|-------|
| 2 | 8/5 | 3/2 | 16/11 |
| 3 | 9/5 | **27/17 > 3/2** | 3/2 |
| 4 | 32/17 | 8/5 | 64/43 |
| 5 | 25/13 | 75/47 | 25/17 |
| 6 | 72/37 | 27/17 | 16/11 |

`r = 2` rises monotonically towards `2` from below; `r ≥ 3` overshoots its
limit `r/(r-1)` at finite dial sizes (`manyFactor_overshoot`) — a structural
difference between semiprimes and multi-prime moduli found by this table.
Exploratory argmax scan over `K ≤ 200`: the best dial is `K = 4` for `r = 3`,
`K = 3` for `r = 4,5,6`, and `K = 2` for every `7 ≤ r ≤ 14`; the maximal ceiling
is `1.6, 1.5, 1.452, …, 1.379 (r = 10), 1.3338 (r = 1000)`.  This led to the
proved theorems `manyFactor_binary_dial_optimal` (`K = 2` is optimal for all
`r ≥ 7`) and `manyFactor_collapse_to_four_thirds` (`4r/(3r-1) → 4/3`).

## 4. Guessing bound counter-example hunt (exploratory)

For every `M ≤ 8`, `B ≤ 4` and **every** hint `H : Fin M → Fin B` (all `B^M`
maps), the best strategy (in-fibre ranking) was compared with the bound
`2 Σ g ≥ M²/B + M`: **0 violations in 32 `(M,B)` pairs; 16 pairs tight**
(exactly those with `B | M`, matching `guessing_bound_attained`).

## 5. Noise thresholds in the fallback model (`θ = 1/2`)

Internal (uninformative) filter: `ε < 1/3`; perfect which-factor hint:
`ε < 3/7` (`noise_tolerance`, `noise_tolerance_half`).  These differ from the
paper's `1/6` and `3/5`, which use a cost accounting not reconstructed here;
the qualitative ordering (external tolerates more noise than internal) is
proved for every `θ ∈ (0,1)`.
