# Computational evidence

## Small cases

For a constant success probability `q`, each unit bet has expected payoff

| `q` | expected payoff per card |
|---:|---:|
| `0` | `-1` |
| `1/3` | `-1/3` |
| `1/2` | `0` |
| `2/3` | `1/3` |
| `1` | `1` |

Thus at `q = 2/3`, totals for `n = 1, 2, 3, 10, 1000` are respectively `1/3, 2/3, 1, 10/3, 1000/3`. The 1000-round identity is machine-checked by `thousand_round_exact_two_thirds`.

For deterministic play, small truth tables already exhibit the obstruction. With one card, a prediction scores `+1` in the agreeing world and `-1` in the complementary world. With two cards, complementary-world payoff pairs can be `(2,-2)`, `(0,0)`, or `(-2,2)`. Their average is always zero. The general identities are machine-checked by `totalPayoff_complement` and `complementary_pair_average_zero`.

## Counterexample hunt

The proposed unconditional guarantee fails on a direct family of counterexamples: for any deterministic strategy on `n` cards, settle every card as the Boolean complement of its prediction. The payoff is exactly `-n`. This is proved for every finite `n` by `adversarial_world_exact`, rather than inferred only from sampled computation.

## OEIS search

No OEIS search is relevant. The sequences here are elementary linear payoff sequences (`n/3`, `-n`) rather than a newly observed integer sequence.

## Conclusion from evidence

The numerical target `1000/3` is valid under the explicit assumption of `2/3` predictive accuracy. The evidence does not support deriving that accuracy from logical independence; the formal no-free-lunch theorem shows why an additional semantic/probabilistic assumption is necessary.
