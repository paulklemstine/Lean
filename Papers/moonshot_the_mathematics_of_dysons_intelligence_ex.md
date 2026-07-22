# Computational evidence

The main claims are structural rather than conjectural, but small cases clarify the model.

For `enumerationSchedule n = {n}`, the first six batches are `{0}`, `{1}`, `{2}`, `{3}`, `{4}`, `{5}`. Their cumulative unions have cardinalities `1,2,3,4,5,6`; code `N+1` is absent at deadline `N`, while every fixed code `k` appears at time `k`.

| n | discoveries | `2^n` | `2^(2^n)` |
|---:|:-----------:|------:|------------:|
| 0 | 1 | 1 | 2 |
| 1 | 1 | 2 | 4 |
| 2 | 1 | 4 | 16 |
| 3 | 1 | 8 | 256 |
| 4 | 1 | 16 | 65536 |

No OEIS search is relevant: the sequences used are the standard powers of two and iterated powers of two, not a newly observed sequence.

Counterexample hunt: the singleton schedule is itself a counterexample to the claim that an exponential rate forces some natural-number theorem code never to be discovered. Conversely, every tested finite deadline misses all larger not-yet-enumerated codes, illustrating the proved finite-deadline obstruction.
