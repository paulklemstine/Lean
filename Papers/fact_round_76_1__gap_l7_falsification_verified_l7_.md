# Computational evidence — round-76 #1, GAP-L7 falsification and L7'

Script: `ResearchOutput/scripts/2026-08-31-round76/signflip_evidence.py`
Raw output: `ResearchOutput/scripts/2026-08-31-round76/signflip_evidence_out.txt`
(seed 20260831, n = 1500 draws per band, 24-bit `p`, Miller–Rabin primality.)

Everything below is *exploratory* evidence gathered before formalisation. The
statements that are actually **verified** are the Lean theorems in
`Catalog/Novelty/Reorder*.lean`; the Monte-Carlo table is not a proof.

## 1. Model

A draw is a genuine semiprime `N = p·q`, `p ≤ q`, with balance ratio
`r = q/p` drawn in `[1, 1+δ]`. The generator advertises hard balance `q < 2p`,
so the committed **balance window** is `[√N/√2, √N]`. In units of `√N` the
factor sits at `u = p/√N = 1/√r ∈ (1/√2, 1]`, and the two committed REORDER
policies pay

* window-ascending: `u - 1/√2`
* window-descending: `1 - u`

The **tilt** is `z = (u - 1/√2)/(1 - 1/√2) ∈ [0,1]`; `z < 1/2` is bottom-heavy.

## 2. Small-case / Monte-Carlo table

| δ (band width) | E[asc] | E[desc] | desc/asc | tilt z | winner |
|---|---|---|---|---|---|
| 1.00 | 0.11904 | 0.17386 | 1.4605 | 0.4064 | asc |
| 0.90 | 0.13164 | 0.16125 | 1.2249 | 0.4495 | asc |
| 0.85 | 0.13822 | 0.15467 | 1.1190 | 0.4719 | asc |
| 0.81 | 0.14362 | 0.14927 | 1.0393 | 0.4904 | asc |
| 0.804 | 0.14445 | 0.14845 | 1.0277 | 0.4932 | asc |
| 0.80 | 0.14499 | 0.14790 | 1.0200 | 0.4950 | asc |
| 0.75 | 0.15197 | 0.14092 | 0.9273 | 0.5189 | **desc** |
| 0.50 | 0.19041 | 0.10248 | 0.5382 | 0.6501 | desc |
| 0.20 | 0.24664 | 0.04626 | 0.1875 | 0.8421 | desc |

The winner flips between `δ = 0.80` and `δ = 0.75`, bracketing the analytic
crossover `δ* = 80 - 56√2 = 0.8040405…` proved in
`ReorderL7.signflip_uniform_band`. This is the falsification: the *same* two
committed policies swap extremality inside the admissible generator family.

## 3. Analytic band law (later proved in Lean)

`m(δ) = E[1/√r] = 2/(1 + √(1+δ))` (from `∫₁^{1+δ} r^{-1/2} dr / δ`):

| δ | m(δ) | tilt z | desc/asc |
|---|---|---|---|
| 1.000000 | 0.828427 | 0.414214 = √2 − 1 | 1.414214 = √2 |
| 0.804041 | 0.853553 = (2+√2)/4 | 0.500000 | 1.000001 |
| 0.500000 | 0.898979 | 0.655094 | 0.526498 |
| 0.200000 | 0.954451 | 0.844486 | 0.184152 |

Constants: crossover mean `(2+√2)/4 = 0.8535534`, reciprocal
`4 − 2√2 = 1.1715729` (the ledger's `E[√r] = 1.1716`), hard-balance tilt
`√2 − 1 = 0.4142136`, hard-balance ratio exactly `√2`.

Monte-Carlo tilt at `δ = 1` is 0.4064 against the analytic 0.41421 — the
residual is finite-sample plus the `nextprime` rounding of `q`. Formal
counterparts: `ReorderL7.meanInvSqrt_eq`, `hard_balance_tilt`,
`hard_balance_ratio`.

## 4. Wheel calibration

`φ(30) = 8`, so the mod-30 wheel keeps `4/15` and the protocol-A T1 law caps the
speedup at `30/φ(30) = 3.75`. Reported measurements and their recomputed gaps:

| measured | gap to 3.75 |
|---|---|
| 3.7331 | 0.4507 % |
| 3.741 (headline) | 0.2400 % |
| 3.7496 | 0.0107 % |

(The brief quoted 0.25–0.31 %; the recomputation gives 0.24 % for the headline
cell, which is what the Lean bracket `wheel_gap_bracket` certifies.)

## 5. Counterexample hunt / cap audit

All 13 reported cells (wheel arm, keyed and fixed mod-3 arms on BAL_prime and
P137, narrow-band window arm, paper-137 truncated-ascending arm, the two exp570
ladder surrogates, and the hybrid window×wheel stress arm) were checked against
`S ≤ (4/3)·min(1/μ, 2^k)/Λ`: **0 violations**. Formal counterpart:
`ReorderL7Cap.audit_zero_violations` (`decide`-free, `norm_num` per cell).

Non-vacuity probe: on the hybrid cell (`Λ = 0.7533`) booking `μ = 1` gives a cap
of `1.7700 < 4.06`, while the structural `μ = φ(30)/30` gives `6.6375 ≥ 4.06`.
Formal counterpart: `ReorderL7Cap.hybrid_cap_nonvacuous`.

## 6. OEIS

No integer sequence is produced by this model; the objects are algebraic
constants (`4 − 2√2`, `80 − 56√2`, `√2 − 1`), so no OEIS lookup applies.


# Paper 221 — GAP-L7 falsified and replaced: the extremal enumeration order is a population property

Round-76 #1, theory deliverable (papers-only bump; no new experiment id).
All claims below are backed by machine-checked Lean 4 proofs in
`Catalog/Novelty/Reorder*.lean`; every file compiles with no `sorry` and uses
only the standard axioms `propext`, `Classical.choice`, `Quot.sound`.

## 1. The action space

A `REORDER`-class policy commits ex ante to an enumeration of the candidate
index set (uniformity: one rule for all `N`; test-blindness: the order may not
consult the answers of the probes it schedules). Formally the object is a
permutation of the slots and the cost of a draw is the probe index at which the
hit is visited:

`probeCost w a = ∑_k (k+1)·w (a k)`.

**Theorem (exchange / L7-b, `probeCost_masssort_le`).** If `w ∘ a` is antitone
then `probeCost w a ≤ probeCost w b` for every enumeration `b`.

This is the *only* order-optimality statement the action space supports. It
names no arithmetic order. Which concrete enumeration realises the mass sort is
a property of the population.

## 2. Failure 1 — the prior-shape channel Λ, with an exact sign flip

Model: `N = p·q`, `p ≤ q`, balance ratio `r = q/p ∈ [1,1+δ]`, so
`p/√N = 1/√r`. A generator advertising `q < 2p` licenses the window
`[√N/√2, √N]`; in units of `√N` the ascending scan pays `1/√r − 1/√2` and the
descending scan pays `1 − 1/√r`.

* **Population criterion (`pop_signflip`).** For any finite population,
  ascending wins iff `E[1/√r] < (2+√2)/4`. In the ledger's reciprocal
  convention the crossover constant is `2/(1+1/√2) = 4 − 2√2 = 1.171572…`
  (`crossoverRecip_eq`, `crossoverRecip_bounds`).
* **Uniform band mean (`meanInvSqrt_eq`).** For `r ~ U[1,1+δ]`,
  `E[1/√r] = 2/(1 + √(1+δ))`, computed from `∫₁^{1+δ} r^{-1/2} dr`.
* **Sign-flip law (`signflip_uniform_band`).** Ascending beats descending **iff**
  `δ > 80 − 56√2 = 0.804041…`.
* **Hard balance (`hard_balance_tilt`, `hard_balance_ratio`).** At `δ = 1` the
  tilt is exactly `√2 − 1 = 0.414214` (bottom-heavy) and descending costs exactly
  `√2` times ascending.
* **Falsification (`L7_as_drafted_false`).** `δ = 1` and `δ = 1/2` are both
  admissible and the same two committed policies swap winners.
* **Universality (`signflip_window_family`, `crossoverWidthK_lt_band`,
  `signflip_universal`).** For a generator advertising `q < k·p` the crossover is
  `δ*(k) = 8√k(√k − 1)/(√k + 1)²`, and `δ*(k) < k − 1` for every `k > 1`: the
  crossover always lies strictly inside the admissible band range, so the
  falsification is a property of the whole window family.

Monte-Carlo over genuine semiprimes (n = 1500 per band, seed 20260831) brackets
the `k = 2` crossover between `δ = 0.80` (ascending wins, desc/asc = 1.0200) and
`δ = 0.75` (descending wins, desc/asc = 0.9273); see `ComputationalEvidence.md`.
Paper 137's pool is *refined, not contradicted*: its band is narrow enough to sit
on the descending side of the crossover.

## 3. The corrected master inequality L7'

**Theorem (`speedup_le_capL7`).** From the touch floor
`Λ·μ_eff·C_desc ≤ (4/3)·C_A` and the bit floor `Λ·C_desc ≤ (4/3)·2^k·C_A`,

`S ≤ (4/3)·min(1/μ_eff, 2^k)/Λ`.

* **Touch floor is a theorem, not a booking (`speedup_le_inv_mu`).** A policy
  that still keeps a `μ`-fraction of the `M` candidates pays at least
  `(μM+1)/2` probes, hence `S ≤ 1/μ`.
* **Audit (`audit_zero_violations`).** All 13 reported cells (wheel arm,
  keyed/fixed mod-3 arms, narrow-band and paper-137 window arms, ladder
  surrogates, hybrid stress arm) satisfy the cap: zero violations.
* **Vacuity boundary (`pure_permutation_cap_const`, `hybrid_cap_nonvacuous`).**
  Booking `μ = 1` collapses the cap to the constant `4/3`; on the hybrid
  window×wheel cell the reported `S = 4.06` breaks the `μ = 1` cap (`1.77`) and
  satisfies the structural one (`6.64`). Structural `μ` extraction is
  load-bearing.
* **Keep fraction extracted (L7-d: `card_coprime_block`,
  `touched_card_reorder_invariant`, `wheel_speedup_le`, `wheel_thirty_law`).**
  A mod-`M` wheel leaves exactly `φ(M)·m` of `M·m` candidates; reordering is a
  bijection and cannot change that count; hence `S ≤ M/φ(M)`, and at `M = 30`,
  `S ≤ 15/4 = 3.75`. The wheel arm measured 3.7331–3.7496 (recomputed gaps
  0.45 % / 0.24 % / 0.01 %).

## 4. Witness corrections

* **Jacobi witness retracted (`jacobi_witness_degenerate`,
  `jacobi_witness_constant`, `jacobi_nonzero_of_coprime`).** For `N = p·q` the
  symbol `(N | p)` vanishes identically because `p ∣ N`; being constant over the
  draw space it carries zero bits. Away from the factor the symbol is nonzero,
  so the vanishing is a degeneracy of the witness, not of the symbol.
* **Keyed-vs-fixed control (`mod3_promotion_factor_blind`, and at general
  modulus `keyed_promotion_factor_blind`, `keyed_promotion_share`).** Selecting
  one residue class promotes exactly the same number of candidates for every
  key, so an `N`-keyed rule and a fixed-key rule are statistically identical:
  residue couplings carry zero information and apparent gains are prior-shape
  leakage.
* **exp570 transfer bounded (`frontload_le`, `cost_eq_tail_sums`).** What
  transfers from the early-fire trace is *front-loading ⇒ head domination*, an
  Abel-summation fact about prefix masses. It does not imply
  `√N`-descending dominance; the direction is settled only by the population.
* **No free lunch (`flat_prior_cost`).** Against a flat prior every enumeration
  costs `(n+1)/2`; every REORDER gain is a prior-shape gain.

## 5. L7-a : certifying Λ from a lab measurement

`Λ_lab(m) = (1 − m)/(m − 1/√2)` is strictly antitone in the measured mean
(`Lambda_antitone`), so a measurement `m̂ ± ε` brackets it (`Lambda_bracket`),
and if `m̂ + ε` still clears the crossover the extremal order is certified with
gain `> 1` (`signflip_certified`; instantiated at the round-74 hard-balanced
pool in `hard_balanced_pool_certified`).

## 6. Status of the ledger

| item | status |
|---|---|
| L7 as drafted | **false** (`L7_as_drafted_false`, `signflip_universal`) |
| L7' master cap | **proved** (`speedup_le_capL7`), audit clean |
| L7-a measured Λ | **closed** (certification theorems) |
| L7-b exchange | **closed** (`probeCost_masssort_le`) |
| L7-c touch floor | **closed** (`speedup_le_inv_mu`) |
| L7-d structural μ | **closed for wheels** (`wheel_speedup_le`) |
| L7-e unconditional factor blindness | **open** (relativized route in `FUTURE_DIRECTIONS.md`) |

No breakthrough claimed: this is falsification-and-replacement inside the
barrier map. The barrier-4 positional stratum gains a measurable, sign-flipping
prior-shape channel with a closed-form crossover; the residue cap `4/3` is
untouched.
