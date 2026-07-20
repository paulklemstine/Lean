# Computational evidence

The formal development concerns a closed-form optimization law rather than a newly observed integer sequence, so the evidence is a concise exact rational test.

## Small-case calculation

For five cards with truth probabilities

| card | `q` | Bayes prediction | optimal expected contribution `|2q-1|` |
|---:|---:|:---:|---:|
| 0 | `1/2` | true (tie convention) | `0` |
| 1 | `2/3` | true | `1/3` |
| 2 | `1/4` | false | `1/2` |
| 3 | `9/10` | true | `4/5` |
| 4 | `0` | false | `1` |

The total is `0 + 1/3 + 1/2 + 4/5 + 1 = 79/30`.  This calculation is encoded and kernel-checked as the concrete `example` in `NumberTheory/BayesianCasino.lean`.

## Counterexample hunt

The exact regret identity shows what any counterexample to Bayes optimality would require: a negative term among `0` and `2 * |2q-1|`.  Every such term is nonnegative, so no rational finite deck can be a counterexample.  The formal theorem `bayesian_regret_exact` proves this symbolically for every deck size, every rational marginal vector, and every deterministic strategy.

For the worst-case mixed-strategy claim, every test world is paired with its Boolean complement.  Their payoffs are exact negatives by `mixedPayoff_complement`; therefore at least one member of every pair is nonpositive.  This symbolic pairing exhausts all finite dimensions and is stronger than sampling.

## OEIS search

No OEIS search is applicable: the result is a parameterized rational identity, not a distinguished integer sequence.
