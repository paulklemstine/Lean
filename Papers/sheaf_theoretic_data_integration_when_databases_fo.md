# Computational evidence

## Scope

The formal development proves a deterministic gluing theorem, so its core
claim is structural rather than numerical. Small finite cases nevertheless
illustrate the overlap-consistency criterion and also expose why the proposed
probability law needs extra modeling assumptions.

## Small cases

Take Boolean-valued columns. Two views on column sets `U` and `V` glue exactly
when all entries in `U ∩ V` agree.

| overlap size `c` | assignments to each view on the overlap | compatible ordered pairs | fraction compatible |
|---:|---:|---:|---:|
| 0 | 1 | 1 | 1 |
| 1 | 2 | 2 of 4 | 1/2 |
| 2 | 4 | 4 of 16 | 1/4 |
| 3 | 8 | 8 of 64 | 1/8 |

For an alphabet of size `q`, independently uniform overlap values agree with
probability `q^{-c}`. This depends on the value distribution and alphabet,
not merely on a missing-entry rate.

For `k` local views, one potential pairwise overlap constraint is associated
to every unordered pair. The first counts are

| `k` | `choose(k,2)` |
|---:|---:|
| 0 | 0 |
| 1 | 0 |
| 2 | 1 |
| 3 | 3 |
| 4 | 6 |
| 5 | 10 |
| 6 | 15 |

## OEIS search result

The sequence `0, 0, 1, 3, 6, 10, 15, ...` is the triangular-number sequence,
OEIS A000217 (with indexing beginning at `k = 0` as `choose(k,2)`).

## Counterexample hunt / model critique

The universal reading of `P(sheaf) = (1-r)^C` is false without a specified
random model. With no missing cells (`r = 0`) and two Boolean records that
independently choose different values on their single shared column, the
records are incompatible, while the formula predicts probability `1`.
Conversely, if all observed entries come by restriction from a fixed ground
truth global record, every pair is compatible for every missing rate, so the
probability of extendability is `1`, not `(1-r)^C` in general.

The power law is valid under the explicit assumption that there are `C`
independent constraints and each succeeds with probability `1-r`; the existing
formal file `Catalog/Bridges/ProbabilityAndStochastics/SheafImputationProbability.lean`
proves the associated finite-product identity and decay results. The new Lean
formalization instead proves the model-independent mathematical core: overlap
agreement gives a unique glued record.
