# Computational Evidence

## Small cases

For a periodically pruned binary search, `freeCount m R n` counts the branching levels below depth `n` whose residue modulo `m` lies in `R`.

The executable checks already embedded in `Catalog/Algebra/TruthFractalDimensionDeepening.lean` give:

| model | depths | `freeCount` values |
|---|---:|---|
| `m = 2`, `R = {0}` | `0,…,5` | `0, 1, 1, 2, 2, 3` |
| `m = 3`, `R = {0}` | `0,…,8` | `0, 1, 1, 1, 2, 2, 2, 3, 3` |

For `m = 2`, `R = {0}`, and depth `4`, the accepted-prefix count is
`2 ^ freeCount 2 {0} 4 = 4`.

At complete periods, the new benchmark theorem predicts exact finite estimates. For example, with `p = 2`, `q = 3`, and `k = 4`, depth `q*k = 12` has free count `p*k = 8`, so the normalized estimate is `8/12 = 2/3`, exactly the limiting dimension.

## OEIS search

No OEIS search is relevant: the sequences are elementary periodic counting functions, explicitly given by filtered residue counts, rather than an unidentified integer sequence.

## Counterexample hunt

The proposed super-unit regime is ruled out universally by the formal theorem `searchDim_le_one`, so small-case searching cannot produce a counterexample to that bound. Endpoint and interior checks (`0`, `1/2`, `2/3`, and `1`) agree with the proved interval `[0,1]`.

The claim that dimension determines shortest-proof length is refuted parametrically rather than experimentally: `benchmark_does_not_determine_length` constructs, for every natural `L`, an instance with the same prescribed dimension and exact complete-period estimate but shortest-proof field equal to `L`.

## Plot/table interpretation

The tables above form staircases with slopes `1/2` and `1/3`. At period boundaries the staircases meet their limiting lines exactly; this is formalized by `finiteEstimate_at_periods` and combined with rational realization in `periodic_search_benchmark`.
