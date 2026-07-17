# Computational evidence

The principal positive claims are structural and universally quantified, while the contrarian claim has a simple finite illustration.

## Small cases

For target set `A = {1,2,4,8,16,…}`, the cutoff is

| `n` | in `A` | cutoff `f(n)` | residual `n-f(n)` | residual in `{0}` |
|---:|:---:|---:|---:|:---:|
| 1 | yes | 1 | 0 | yes |
| 2 | yes | 2 | 0 | yes |
| 3 | no | 2 | 1 | no |
| 4 | yes | 4 | 0 | yes |
| 5 | no | 4 | 1 | no |
| 6 | no | 5 | 1 | no |
| 7 | no | 6 | 1 | no |
| 8 | yes | 8 | 0 | yes |
| 9 | no | 8 | 1 | no |
| 16 | yes | 16 | 0 | yes |

Thus shifting the singleton spectrum `{0}` by this cutoff reproduces powers-of-two membership at every positive index. This identity is proved for all positive natural numbers by `adversarial_pruning_encodes_arbitrary_tail` and its specialization `powersOfTwo_pruning_counterexample`.

For count saturation with threshold `q = 3`, representative additions are:

| `a ~ b` | `c ~ d` | sums | conclusion |
|---|---|---|---|
| `1 ~ 1` | `2 ~ 2` | `3 ~ 3` | equal |
| `3 ~ 8` | `1 ~ 1` | `4 ~ 9` | both saturated |
| `0 ~ 0` | `5 ~ 7` | `5 ~ 7` | both saturated |
| `4 ~ 9` | `6 ~ 3` | `10 ~ 12` | both saturated |

The universal statement is proved by `countEquivalent_add`.

## Sequence identification

The powers-of-two sequence begins `1, 2, 4, 8, 16, 32, 64, …` and is OEIS A000079.

## Counterexample hunt

The unrestricted conjecture “a varying pruning shift preserves eventual periodicity” fails. The formal counterexample starts from `{0}`, which is eventually periodic, and uses the cutoff above. The resulting spectrum agrees on its positive tail with the powers of two, formally proved not eventually periodic. The combined existential disproof is `exists_pruning_destroys_eventualPeriodicity`.

No numerical simulation is needed for the asymptotic probabilistic claims because those claims are not asserted in the Lean artifact; developing their probability models and estimates remains future work.
