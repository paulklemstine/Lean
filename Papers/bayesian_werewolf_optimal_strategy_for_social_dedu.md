# Computational Evidence: Bayesian Werewolf

## Model used for the small-case calculation

A deliberately information-free baseline was fixed before calculation. At each day vote, a uniformly random surviving player is eliminated. If that player is a wolf, the following night removes one villager unless the eliminated wolf was the last wolf. If the day eliminates a villager, the night removes one further villager. Villagers win at zero wolves; wolves win once wolves equal or outnumber villagers.

Writing `D(v,w)` for the village win probability with `v` villagers and `w` wolves,

`D(v,w) = w/(v+w) D(v-1,w-1) + v/(v+w) D(v-2,w)`,

with `D(v,0)=1` and `D(v,w)=0` for `w≥v`. The last-wolf branch is interpreted as an immediate village win.

## Small-case calculations (`k=2`)

| total players `n` | exact `D(n-2,2)` | decimal | ratio to `(1-2/(n-2))²` |
|---:|---:|---:|---:|
| 7 | `8/35` | 0.228571 | 0.634921 |
| 8 | `5/32` | 0.156250 | 0.351562 |
| 9 | `94/315` | 0.298413 | 0.584889 |
| 10 | `69/320` | 0.215625 | 0.383333 |
| 11 | `244/693` | 0.352092 | 0.582030 |
| 12 | `203/768` | 0.264323 | 0.413005 |
| 13 | `1186/3003` | 0.394938 | 0.589970 |
| 14 | `1093/3584` | 0.304967 | 0.439152 |
| 15 | `2768/6435` | 0.430148 | 0.600785 |
| 16 | `2781/8192` | 0.339478 | 0.462067 |
| 17 | `50294/109395` | 0.459747 | 0.612089 |
| 18 | `54445/147456` | 0.369229 | 0.482258 |
| 19 | `112028/230945` | 0.485085 | 0.623065 |
| 20 | `129503/327680` | 0.395212 | 0.500190 |

The pronounced even/odd oscillation means that a single constant multiplying the proposed quadratic does not describe even this baseline over `7≤n≤20`. The ratio ranges from approximately `0.3516` to `0.6349`.

## Counterexample hunt

Two conjectures fail without extra assumptions.

1. **Universal seven-player value.** The exact baseline value is `8/35≈0.2286`, not `0.36`. The exact identity and strict comparison with `9/25` are proved in `Catalog/Applications/BayesianWerewolf/Evidence.lean`.
2. **Global MAP optimality.** With posterior `(3/5,2/5)`, immediate MAP selects suspect `0`. If a correct elimination of suspect `0` pays `1/10` while a correct elimination of suspect `1` pays `1`, expected values are `3/50` and `2/5`; therefore suspect `1` is globally preferable. This finite counterexample is proved in `Core.lean`.

## Sequence search

No OEIS identifier is claimed. The recurrence depends on game-specific absorbing boundaries and move order, and the first terms exhibit parity effects; no reliable identification was established.

## Conclusion

The computational landscape supports a guarded theorem: MAP voting maximizes immediate correctness and also maximizes continuation value when continuation rewards are identity-symmetric and a correct elimination is weakly preferable. It contradicts an unconditional global-optimality claim and any model-independent numerical scaling law.
