# Computational evidence — BATTERY-CAPACITY / SYNERGY-COMPOUNDS (round 27 #2)

All numbers below come from `evidence_batterysynergy.py` in this repository
(plain plug-in/empirical estimates, `python3 evidence_batterysynergy.py`).
They are **exploratory**: only the statements in `Catalog/MachineLearning/BatterySynergy/`
are machine-checked. Where a number below is also a theorem, it is flagged.

## 1. Small cases: the parity battery on the cube

Population `{0,1}^k` (all `2^k` individuals, so these are exact, not sampled),
dials = coordinates, label = parity of all coordinates.  For each order `r` the
range of `I(label ; dials in S)` over all `|S| = r` is shown.

| k | H(label) | order 1 | order 2 | order 3 | order 4 | order 5 |
|---|---|---|---|---|---|---|
| 2 | 1.0000 | [0, 0] | [1, 1] | | | |
| 3 | 1.0000 | [0, 0] | [0, 0] | [1, 1] | | |
| 4 | 1.0000 | [0, 0] | [0, 0] | [0, 0] | [1, 1] | |
| 5 | 1.0000 | [0, 0] | [0, 0] | [0, 0] | [0, 0] | [1, 1] |

Every proper sub-battery carries exactly `0` bits; the full battery carries
exactly `1` bit = the label-entropy ceiling.  **Proved** in
`ParityBattery.info_proper_eq_zero` / `ParityBattery.info_univ_eq_one` for all
`k`, and independently (by a `decide`-based fibre count) for `k = 3` in
`ParityWitness.parity_capacity_is_purely_higher_order`.

Order decomposition for `k = 4` (total synergy per order), the analogue of the
table in the round-27 report:

| order | total synergy |
|---|---|
| 2 (6 pairs) | +0.0000 |
| 3 (4 triples) | +0.0000 |
| 4 (the battery) | **+1.0000** |

i.e. the extreme point of "synergy compounds": `100 %` of the capacity is
order-`k`.  **Proved** in `ParityBattery.synergy_is_order_k`.

## 2. A CRT dial battery on a semiprime population

`30 000` semiprimes `N = p q` with `p, q` uniform in the primes below `20 000`;
dials `N mod 31, N mod 23, N mod 9, N mod 8` (CRT modulus `51 336`); label the
symmetric pair `(p mod 4, q mod 4)` (this is *a* symmetric label, not the one of
the round-27 run, so the numbers differ from the report).

```
per-dial:      mod 31: 0.0019   mod 23: 0.0016   mod 9: 0.0002   mod 8: 1.0000
Σ marginals  = 1.0037 bits
joint (51336)= 1.4409 bits          synergy = +0.4371 bits
label ceiling= 1.9999 bits
order 2 total synergy = +0.0663
order 3 total synergy = +0.4309
order 4 total synergy = +0.4371
```

Qualitatively this reproduces the reported structure: the joint sits strictly
between `Σ` marginals and the joint label-entropy ceiling, the synergy is
positive, and the pairwise total is a small fraction (here `15 %`) of the
order-4 total, with order 3 carrying almost all of it.  These plug-in figures
are *not* verified; they only motivated the theorems.

## 3. Counterexample hunt

* *Is capacity additive?*  No — refuted already at `k = 2` above (`0 + 0 < 1`).
  Formally, `ParityBattery.synergy_is_order_k` gives a battery with
  `Σ marginals = 0 < 1 = info`, so **no** bound `info ≤ c · Σ marginals` holds
  for any constant `c`.
* *Is capacity monotone in the battery?*  No counterexample was found, and this
  is now a theorem (`BatterySynergy.info_mono`, via the data processing
  inequality `BatterySynergy.MI_comp_le`).
* *Is total synergy monotone in the battery?*  No: enlarging a battery adds the
  new marginals to the subtracted term.  We therefore only claim the two-sided
  bounds `synergy_le_label_entropy`, `synergy_ge_of_mem` and the budget
  `synergy_le_unused_code`.
* *Can synergy exceed the label entropy?*  No — `synergy_le_label_entropy`.
  Searches over random small populations (not reported here) found no violation,
  consistent with the theorem.

## 4. Sequences

No integer sequence arises here that warranted an OEIS lookup: the exact values
are `0` for every proper sub-battery and `1` for the full battery, and the fibre
counts are the powers of two `2^(k-|S|)` and `2^(k-|S|-1)` that appear in
`ParityBattery.card_agree` and `ParityBattery.card_agree_parity`.
