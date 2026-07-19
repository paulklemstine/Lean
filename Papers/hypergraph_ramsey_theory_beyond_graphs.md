# Computational Evidence

## Small-case calculations

The Property-B transfer criterion for 3-uniform diagonal Ramsey avoidance is

`C(n,k) < 2^(C(k,3)-1)`.

For `k = 3`, the right side is `1`. The criterion holds precisely when `n<3`, since then `C(n,3)=0`; this is consistent with the exact boundary value `R₃(3,3)=3`.

For `k = 4`, the right side is `8`. The inequality holds through `n=4`, where `C(4,4)=1`, but fails at `n=5`, where `C(5,4)=5` still actually remains below 8; it first fails at `n=6`, where `C(6,4)=15`. Thus this elementary criterion only witnesses avoidance through five vertices, far below the exact value `R₃(4,4)=13`.

For `k = 5`, the right side is `2^9=512`. The values near the cutoff are `C(11,5)=462` and `C(12,5)=792`; hence the transfer theorem proves `R₃(5,5)>11`.

For `k = 6`, the right side is `2^19=524288`. The values near the cutoff are `C(29,6)=475020` and `C(30,6)=593775`; hence the same criterion witnesses avoidance through 29 vertices.

| k | C(k,3) | threshold 2^(C(k,3)-1) | largest n certified |
|---:|---:|---:|---:|
| 3 | 1 | 1 | 2 |
| 4 | 4 | 8 | 5 |
| 5 | 10 | 512 | 11 |
| 6 | 20 | 524288 | 29 |

## OEIS search results

No OEIS identification is needed for the binomial and power sequences used here. The target sequence of exact diagonal 3-uniform Ramsey numbers is not known beyond the earliest nontrivial cases, so it does not provide a settled sequence suitable for identification.

## Counterexample hunt

The proposed exhaustive computation of `R₃(k,k)` for `k=5,6` is infeasible with present brute-force methods: even for 55 vertices, a colouring assigns colours to `C(55,3)=26235` triples. More importantly, the exact values are not presently known. Consequently no claim of an exhaustive determination is made.

The finite arithmetic instances supporting the proved transfer result were checked at the cutoff: `462 < 512`, whereas `792 ≥ 512`; and `475020 < 524288`, whereas `593775 ≥ 524288`. These calculations test the theorem's numerical boundary, not the true Ramsey-number boundary.

## Interpretation

The data do not verify double-exponential growth. Four small values—two of which remain unknown—could not establish an asymptotic growth class in any event. The useful experimental outcome is instead structural: the first-moment lower bound is exactly the sparse Property-B threshold of the clique-incidence hypergraph, and its weakness at `k=4` identifies overlap structure as the natural target for stronger methods.
