# Computational evidence — NET-83 (THE-INTEGRATION-IS-SUPER-ADDITIVE)

All formal claims live in `Catalog/Applications/NET83SuperAdditiveIntegration.lean`.
This note records the numerical exploration that shaped those statements.
**Status labels**: *Lean-verified* = discharged inside the Lean file;
*exploratory* = ad-hoc Python, not machine-checked.

## 1. The reported table, recomputed (Lean-verified)

Losses relative to fp32 retained accuracy, `loss = 1 − retained`:

| k  | loss(attn) | loss(GPTQ4) | loss(both) | additive | interaction |
|----|-----------|-------------|------------|----------|-------------|
| 16 | 0.0232    | 0.0919      | 0.1402     | 0.1151   | **0.0251**  |
| 20 | 0.0197    | 0.0919      | 0.1293     | 0.1116   | **0.0177**  |
| 24 | 0.0149    | 0.0919      | 0.1228     | 0.1068   | **0.0160**  |

Positivity of the three interaction costs and their strict decrease in `k` are
proved in Lean as `NET83.net83_table_superadditive_and_antitone`; the
cross-entropy version is `NET83.net83_crossentropy_superadditive`.

## 2. Does the `σ²(1/k − 1/n)` law fit? (exploratory)

Solving `interaction = σ²(1/k − 1/n)` for the implied noise scale, for three
plausible effective context lengths `n`:

| n   | k=16  | k=20  | k=24  |
|-----|-------|-------|-------|
| 64  | 0.536 | 0.515 | 0.614 |
| 128 | 0.459 | 0.420 | 0.473 |
| 256 | 0.428 | 0.384 | 0.424 |

The implied `σ²` is roughly constant across `k` (spread ≈ ±10% at `n = 128`),
i.e. the measured decay of the interaction cost is consistent with the
`1/k` law that the mean-square theorem predicts. The `k = 24` point is
slightly high, so the fit is suggestive, not conclusive — which is why the
Lean statement is the *identity inside the model*
(`NET83.meansquare_interaction_exact`) plus a qualitative monotonicity claim
(`NET83.worstBound_antitone`, `NET83.noiseEnergy_strictAnti`), and not a
quantitative claim about the language model itself.

## 3. Worst-case interaction, sampled (exploratory)

Random search over zero-mean, sup-bounded (`ε = 1`) error vectors, maximising
`|avg_S η|`:

| n | k | predicted `min(1,(n−k)/k)` | best sampled |
|---|---|---------------------------|--------------|
| 4 | 2 | 1.000 | 0.974 |
| 6 | 2 | 1.000 | 1.000 |
| 6 | 4 | 0.500 | 0.500 |
| 8 | 3 | 1.000 | 0.977 |

No sample ever exceeded the predicted bound, and the bound is approached in
every case. The exact statement is proved in Lean in two halves:
`NET83.interaction_worstcase_le` (never exceeded) and
`NET83.interaction_worstcase_attained` (attained).

## 4. Monte-Carlo check of the mean-square identity (exploratory)

Rademacher error of scale `σ`, random Gaussian values, `4·10⁵` trials:

| n  | k | σ    | MC interaction | `σ²(1/k − 1/n)` |
|----|---|------|----------------|-----------------|
| 8  | 2 | 0.50 | 0.09411        | 0.09375         |
| 16 | 4 | 0.25 | 0.01173        | 0.01172         |
| 12 | 3 | 1.00 | 0.25097        | 0.25000         |

Agreement to sampling error. The exact identity is
`NET83.meansquare_interaction_exact`, instantiated at the Rademacher ensemble
by `NET83.rademacher_interaction_exact`.

## 5. Group-correlated (shared-scale) dither, Monte Carlo (exploratory)

One sign per quantization group of size `g`, `σ = 0.5`, `3·10⁵` trials,
measuring the transmitted variance of a `k`-sparse uniform head:

| n  | k | g | selection      | MC      | predicted |
|----|---|---|----------------|---------|-----------|
| 16 | 4 | 8 | one group      | 0.25000 | `σ² = 0.25000` |
| 16 | 4 | 4 | one per group  | 0.06257 | `σ²/k = 0.06250` |
| 24 | 3 | 8 | one group      | 0.25000 | `σ² = 0.25000` |
| 24 | 3 | 8 | one per group  | 0.08340 | `σ²/k = 0.08333` |

Group-aligned selection transmits the full `σ²` — the sparse average cancels
nothing — while group-spread selection recovers the ideal `σ²/k`. Both are
proved in Lean (`NET83.radG_aligned_full_variance`,
`NET83.meansquare_grouped_spread`), with the general formula in
`NET83.meansquare_avgOn_grouped`.

## 6. Counterexample hunt

Searching for configurations with **negative** interaction succeeded
immediately: with values `(0,0,3,3)`, `S = {0,1}` and error `(1,1,1,−1)` the
combined arm beats the sparse arm. This is recorded honestly in Lean as
`NET83.interaction_can_be_negative` and is why the deliverable states
super-additivity as a worst-case and mean-square phenomenon rather than a
pointwise inequality.

No OEIS sequence is involved: the objects here are real-valued averages, not
integer sequences.
