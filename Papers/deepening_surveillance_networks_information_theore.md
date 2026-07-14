# Computational evidence

The theorems in `BoundedError.lean` are exact combinatorial identities and
inequalities about finite maps, so the "evidence" is a direct check of the
inequalities on small state spaces rather than a numerical experiment.

## 1. The combinatorial Fano bound: `#recon ≤ rate`, `|S| ≤ rate + #errors`

Take `S = {0,1,2,3}` (so `|S| = 4`) and a channel `obs : S → M`.

* **Perfect privacy** `obs ≡ ⋆` (one record): `rate = 1`. Any decoder outputs a
  single fixed configuration, so at most one `s` is reconstructed correctly and
  `#errors ≥ 3 = |S| - 1`. Matches `privacy_error_bound`.
* **Rate 2** channel, e.g. `obs s = s mod 2`, `dec 0 = 0, dec 1 = 1`. Correctly
  reconstructed: `{0,1}`, so `#recon = 2 = rate`, `#errors = 2 = |S| - rate`.
  Matches `reconSet_card_le_rate` and `fano_error_bound` with equality.
* **Rate 4** (injective) channel with matching decoder: `#recon = 4`, `#errors = 0`.
  Here `|S| - k ≤ rate` becomes `4 ≤ 4` at `k = 0`.

These confirm `fano_error_bound` is tight (equality is achievable at every rate).

## 2. Sharp rate–distortion: minimum rate = covering number

Let `S = {0,1,2,3}` on a cycle with `d i j = ` cyclic distance, budget `D = 1`.

* `D = 1` balls have size 3 (each vertex plus two neighbours). The minimum number
  of balls covering the 4-cycle is `2` (e.g. centers `{0, 2}`). So
  `minCover d 1 = 2`.
* An explicit channel realising it: `obs 0 = obs 1 = obs 3 = 0`, `obs 2 = 2`,
  `dec = id`; every vertex is within distance `1` of its assigned center, and the
  channel emits `2` distinct records. So the minimum achievable rate is exactly
  `2 = minCover`. Matches `rate_distortion_sharp`.
* Lowering the budget to `D = 0` forces balls of size 1, `minCover d 0 = 4`, and
  the only distortion-0 channel is injective (rate 4). The covering number grows
  as the budget shrinks — the privacy–utility tradeoff curve.

## 3. Directed networks: bit counts

`|{Fin n → Fin n → Bool}| = 2^{n·n}` (`card_directed_network`); e.g. `n = 2` gives
`16` snapshots, so exact reconstruction needs `log₂ 16 = 4 = n²` bits, and
reconstructing all but `k = 4` of them needs `log₂(16 - 4) = log₂ 12 = 3` bits
(`directed_network_bounded_error_bits`).

## Counterexample hunt

The reflexivity hypothesis `d s s ≤ D` in `rate_distortion_sharp` is necessary:
if `d s s > D` for some `s`, then no `D`-cover exists (a point cannot even cover
itself), the covering set is empty, `sInf ∅ = 0`, yet no channel achieves the
budget — so the "attained" half would be false without the hypothesis. This is
exactly why the theorem carries `hrefl`.
