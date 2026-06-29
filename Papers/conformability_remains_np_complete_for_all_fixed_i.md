# Computational Evidence — odd-order conformability obstruction

All claims below are formalized in `ConformabilityOddOrder.lean` /
`PerfectTrianglePacking.lean`; this note records the small-case data that motivated them.

## 1. The `oddCap` refinement (largest odd ≤ α)

| α | naive cap α | `oddCap α` |
|---|-------------|------------|
| 1 | 1 | 1 |
| 2 | 2 | 1 |
| 3 | 3 | 3 |
| 4 | 4 | 3 |
| 5 | 5 | 5 |
| 6 | 6 | 5 |

For even α, `oddCap α = α − 1`: the parity constraint of odd-order conformability
strictly sharpens the counting bound `n ≤ (d+1)·α` to `n ≤ (d+1)·oddCap α`.

## 2. Small regular graphs of odd order

For a `d`-regular graph of odd order `n` with independence number `α`, conformability
requires `n ≤ (d+1)·oddCap α` (and `d` even).

| graph | n | d | α | (d+1)·oddCap α | conformable? |
|-------|---|---|---|----------------|--------------|
| K₃    | 3 | 2 | 1 | 3·1 = 3 | yes (bound tight; `triangle_conformable`) |
| C₅    | 5 | 2 | 2 | 3·1 = 3 | **no** — `5 > 3`, blocked by the obstruction |
| C₇    | 7 | 2 | 3 | 3·3 = 9 | bound allows it (`7 ≤ 9`) |
| K₅    | 5 | 4 | 1 | 5·1 = 5 | bound tight, `5 ≤ 5` |

C₅ is the cleanest witness that the obstruction has teeth: although the naive bound
`n ≤ (d+1)·α = 6` is satisfied, `oddCap 2 = 1` collapses the true bound to `3 < 5`.

## 3. Perfect triangle packings (`k = 3` case)

A perfect triangle packing partitions `n` vertices into `3`-cliques, so `3 ∣ n`:
`n ∈ {3, 6, 9, 12, …}`.  For odd `n` divisible by `3` (`n ∈ {3, 9, 15, …}`) the number of
triangles is odd, and every class has odd size `3` — exactly a conformable colouring of the
complement.  This matches OEIS A008585 (multiples of 3) intersected with the odds.

## 4. Counterexample hunt

No counterexample to `n ≤ (d+1)·oddCap α` was found among the regular graphs above; the
bound is a *proven* necessary condition (`conformable_odd_order_bound`), so a counterexample
would contradict the Lean theorem.  The hunt instead confirmed tightness (K₃, K₅).
