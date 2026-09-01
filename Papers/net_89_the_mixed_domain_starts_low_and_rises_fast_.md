# Computational evidence — NET-89 mixed-domain key budgets

All numbers below were produced by exact rational arithmetic (Python `fractions`) on the
same objects that the Lean files define: `headMass w k = Σ_{i<k} w i`,
`retained w n k = headMass w (min k n) / headMass w n`, and
`k*(n) = min { k : retained w n k ≥ τ }`.

**Status of this file.** These are *exploratory* computations, not verified artefacts.
Everything that is asserted as a theorem lives in
`Catalog/Probability/NET89MixedDomainKnee.lean` and
`Catalog/Probability/NET89MixingRatioBlocks.lean` and is machine-checked there with no
`sorry`. In particular the three witness knees of §1 below are *also* proved in Lean
(`kstar_uA`, `kstar_uB`, `kstar_uC`, `kstar_vFlat`, `kstar_poolA`, `kstar_poolB`,
`kstar_poolC`), so for those the table is redundant with the formal proof.

## 1. Small cases: the sandwich is exactly attained (P1 refutation)

Context `n = 4`, gate `τ = 0.7`, partner domain `vFlat = (1,1,1,1)` with `k* = 3`.

| head-heavy domain `u`            | `k*_u` | `k*_v` | `k*_{u+v}` | position in `[min, max]` |
|----------------------------------|--------|--------|------------|--------------------------|
| `uA = (10, 1, 1, 1)`             | 1      | 3      | **2**      | midpoint                 |
| `uB = (100, 1, 1, 1)`            | 1      | 3      | **1**      | min                      |
| `uC = (0.1, 0.001, 0.001, 0.001)`| 1      | 3      | **3**      | max                      |

Three profile pairs, identical component knees `(1,3)`, three different mixed knees.
Hence no function of the component knees can predict the mixed knee (Lean:
`no_component_knee_formula`), and in particular the midpoint rule fails (`uB`).

A 100:1 code-dominated mixture `pool 1 (1/100) uA vFlat` has `k* = 1 = k*_uA`
(Lean: `code_dominated_mixture_has_code_knee`).

## 2. The doubling law on a Zipf profile

`u i = 1/(i+1)`, second domain `v = 1.5 · u` (same shape, different mass), interleaved
profile `mix u v`. Pure/pooled increment `Δ = k*(2n) - k*(n)`; mixed increment
`Δ_mix = k*_mix(4n) - k*_mix(2n)`.

| τ    | n   | Δ_pure | Δ_pooled | Δ_mix | 2·Δ_pure | \|Δ_mix − 2Δ_pure\| |
|------|-----|--------|----------|-------|----------|---------------------|
| 0.90 | 128 | 64     | 64       | 129   | 128      | 1                   |
| 0.90 | 256 | 120    | 120      | 240   | 240      | 0                   |
| 0.90 | 512 | 224    | 224      | 448   | 448      | 0                   |
| 0.95 | 128 | 91     | 91       | 181   | 182      | 1                   |
| 0.95 | 256 | 175    | 175      | 351   | 350      | 1                   |
| 0.95 | 512 | 340    | 340      | 679   | 680      | 1                   |
| 0.98 | 128 | 112    | 112      | 224   | 224      | 0                   |
| 0.98 | 256 | 220    | 220      | 440   | 440      | 0                   |
| 0.98 | 512 | 435    | 435      | 869   | 870      | 1                   |

The observed deviation is never more than one key, exactly the slack of
`mix_ctxSens_doubling` / `proportional_mix_increment_doubles`. The reported NET-89 pair
(`+4` pure, `+8` mixed) is the same phenomenon at small budgets.

## 3. Counterexample hunt

300 random sorted positive profile pairs (integer weights `1..50`, contexts
`n ∈ {6,8,12,16}`, gates `τ ∈ {0.50, …, 0.99}`):

* mediant sandwich `min(k*_u, k*_v) ≤ k*_pool ≤ max(k*_u, k*_v)` — **0 violations**;
* mixed bracket `2·k*_pool − 1 ≤ k*_mix(2n) ≤ 2·k*_pool` — **0 violations**;
* midpoint rule `k*_pool = ⌊(k*_u + k*_v)/2⌋` — **10 / 300 mispredictions** (the rule is
  false, as §1 shows, but it is often *accidentally* right, which is how a two-point
  table can appear to support it);
* block bracket `2Q − 2b < k*_block(2bn) ≤ 2Q + 2b` for block sizes `b ∈ {1,2,3,4}` —
  **0 violations**, observed maximal deviation `|k*_block − 2Q| = 2`.

No counterexample to any formalised statement was found; the failures found are failures
of the *report's* P1 midpoint claim, which is what the Lean files refute.

## 4. No OEIS entry

The objects here are gate-dependent knees of real-valued profiles, not an integer
sequence; no OEIS search applies.

## 5. Cycles 5–7: staircase, rigidity, and blocked knees

All computations below are exact-rational (Python `Fraction`), so no floating-point
tolerance is involved. They were run *before* the corresponding Lean proofs, as evidence;
the Lean files are the actual verification.

**(a) Gate staircase (cycle 5).** 200 random positive profiles (`n ∈ {6,8,12}`, integer
weights `1..50`, gates `τ ∈ {0.50,…,0.99}`):

* stability radius `min(τ − R(K−1), R(K) − τ)` — perturbing the gate by `±rad/2` and
  `+rad/3` changed the knee in **0** of the tested cases;
* step-edge instability — at every gate `τ = R(k)` with `1 ≤ k < n`, the knee equals `k`
  and the knee at `τ + w_k/M` equals `k + 1`: **0** exceptions over all profiles and all
  interior `k`.

**(b) Mass-share rigidity (cycle 6).** 300 random pairs with the first domain scaled by
`c ∈ {1,5,20,100}`. In the **133** cases where both mass-share thresholds of
`pool_knee_eq_component_knee_of_dominance` hold, the pooled knee equalled the dominant
component knee in **133/133** cases — **0** violations. (In Lean, the certificate
`dominance_hypotheses_realised` checks one such case symbolically and reproduces the
cycle-1 value `kstar_poolB = 1`.)

**(c) Blocked mixtures (cycle 7).** 400 random pairs, block sizes `b ∈ {1,…,5}`,
`n ∈ {2,…,5}` blocks per domain:

* the two master identities `headMass(mixBlock) (2bq+r) = Hu(bq+r) + Hv(bq)` and
  `headMass(mixBlock) (2bq+b+r) = Hu(bq+b) + Hv(bq+r)` — checked at **every** `q ≤ n`,
  `r ≤ b`: **0** failures;
* the knee reconstructed from the master identities alone (never building the mixed
  context) matched the directly computed blocked knee in **400/400** cases;
* the sharpened aligned bound `k*_block ≤ 2Q + b − (Q mod b)` held in **284/284** cases
  with `Q < bn` — and it is strictly tighter than the cycle-2 bound `2Q + 2b` whenever
  `Q mod b < b`.

**(d) Signal-to-resolution accounting (cycle 13).** 3000 random families (`m ∈ {2,3,4}`
domains, `n ∈ {3,…,6}` keys per domain, integer weights `1..50`, gates
`τ ∈ {0.50, 0.70, 0.90, 0.99}`), with the budget index `k` drawn uniformly in `[0, n)`:

* the conservation inequality
  `Δ_rr · min_j substep_j ≤ Δ_pool · step_pool + step_pool` — **0** violations in 3000
  trials, and the margin was never positive (the bound is never even approached from
  above);
* the balanced case (all `m` domains equal): `min_j substep_j = step_pool / m` held
  exactly in **3000/3000** trials, and `|Δ_rr · substep − Δ_pool · step_pool|
  ≤ (1 − 1/m) · step_pool` in **3000/3000**;
* the skew witness `U = (1, ε)` with `ε = 1/(2C + 2)`: the resolution ratio
  `min substep / step_pool` was `0.0435`, `0.00493`, `0.000499` for `C = 10, 100, 1000`
  respectively — below `1/C` each time, confirming that no fixed fraction of the pooled
  step bounds the resolution from below.

These runs are exploratory numerics only; the verification is
`Catalog/Probability/NET89SignalResolution.lean`, which proves all three statements with
zero sorries.

**(e) The critical weight of a mixing-ratio sweep (cycle 14).** Exact rational evaluation of
the sweep `a ↦ k*(pool a 1 uA vFlat, 4, 7/10)` for the cycle-1 witness pair
`uA = (10, 1, 1, 1)` against `vFlat = (1, 1, 1, 1)`:

| `a` | `1/10` | `2/5` | `8/19 − 10⁻³` | `8/19` | `1/2` | `1` | `199/100` | `2` | `3` | `10` |
|---|---|---|---|---|---|---|---|---|---|---|
| `k*` | 3 | 3 | 3 | 2 | 2 | 2 | 2 | 1 | 1 | 1 |

The two kinks sit exactly at `8/19` and `2`, and the collapse onto the dominant knee `1`
begins precisely at `a = 2`, so the critical weight is `2` — the balanced protocol `a = 1`
lies strictly inside the non-collapsed regime. All entries are exact `Fraction` arithmetic,
and the three regimes are proved in
`Catalog/Probability/NET89CriticalWeight.lean` (`kstar_pool_uA_sweep`, `critWeight_uA_vFlat`)
with zero sorries.

**(f) The closed formula for the critical weight (cycle 15).** Counterexample hunt for the
predicted half-line description of the collapse region. 4000 random exact-rational trials:
context length `n ∈ [2, 6]`, component profiles with integer weights in `[1, 40]`, gate
`τ ∈ {1/20, …, 19/20}`; a trial was retained when the first component dominates the second
at every budget and the dominant excess `Hu(K) − τ·Hu(n)` is positive (`K` the dominant
knee). This left **1117 retained trials**, of which **437** had a strictly positive predicted
critical weight (an interior boundary).

For each retained trial the prediction `collapse at weight a ⟺ a ≥ (τ·Hv(n) − Hv(K)) /
(Hu(K) − τ·Hu(n))` was tested at the seven weights `c/2`, `9c/10`, `c`, `c + 1/7`,
`2c + 1/3`, `1/100`, `50` (with `c` the predicted critical weight), comparing against a
directly computed pooled knee:

| retained trials | interior boundaries | weight checks | mismatches |
|---|---|---|---|
| 1117 | 437 | ≈ 7000 | **0** |

Spot check on the cycle-1 witness pair: `K = 1`, `Hu(1) = 10`, `Hu(4) = 13`, `Hv(1) = 1`,
`Hv(4) = 4`, so the formula gives `(7/10·4 − 1)/(10 − 7/10·13) = (9/5)/(9/10) = 2`, and one
budget down `(7/10·4 − 2)/(11 − 7/10·13) = (4/5)/(19/10) = 8/19` — the two kinks found
independently in (e).

These runs are exploratory numerics only; the verification is
`Catalog/Probability/NET89CriticalWeightFormula.lean`, which proves the equivalence and the
closed formula (`collapse_iff_passWeight_le`, `critWeight_eq_max_passWeight`,
`net89_critical_weight_formula`) with zero sorries.
