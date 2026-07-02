# Computational Evidence: the critical two-vertex augmentation of G27

## 1. The threshold identity

The fractional-colouring engine forces every fractional colouring of a finite graph on `m`
vertices with independence number `a` to have value `> 4` exactly when the independence ratio
`a/m` drops strictly below `1/4`, i.e. when `4a < m`.

For the value `a = 7` that appears in the `G27 / G29` construction:

| added vertices `k` | total `m = 27 + k` | ratio `7/m` | `7/m` vs `1/4` | forces χ_f > 4 ? |
|--------------------|--------------------|-------------|----------------|------------------|
| 0                  | 27                 | 0.25926…    | **above**      | no               |
| 1                  | 28                 | 0.25000     | **equal**      | no (boundary)    |
| 2                  | 29                 | 0.24138…    | **below**      | **yes**          |
| 3                  | 30                 | 0.23333…    | below          | yes              |

The transition happens between `m = 28` and `m = 29`. Because `7/28 = 1/4` is an *exact*
equality, one added vertex only reaches the boundary; two is the least number that crosses it.

## 2. Minimality, general form

For a base of `n` vertices with independence number `a` satisfying `n ≤ 4a` (base at or above
threshold), the least `k` with `a/(n+k) < 1/4` is

```
k_min = 4a − n + 1.
```

Small cases (verified as an exact integer computation):

| `a` | `n`  | `4a` | `k_min = 4a−n+1` |
|-----|------|------|------------------|
| 7   | 27   | 28   | **2**            |
| 7   | 26   | 28   | 3                |
| 7   | 28   | 28   | 1                |
| 6   | 23   | 24   | 2                |
| 8   | 31   | 32   | 2                |

The `G27` case `(a, n) = (7, 27)` is exactly the boundary configuration whose minimal
augmentation is `2`.

## 3. Counterexample hunt (minimality)

We searched over `k = 0, 1` for the specific base `(a, n) = (7, 27)`:

- `k = 0`: `7/27 ≈ 0.2593 ≥ 1/4` — does not cross.
- `k = 1`: `7/28 = 0.2500 = 1/4` — reaches but does not strictly cross.

No `k < 2` crosses the threshold, confirming `k = 2` is minimal. This is formalised as an
`IsLeast` statement.

## 4. Structural (graph) facts

- Passing to an induced subgraph (a sub-configuration of points) can only *decrease* the
  independence number, so augmentation can only *increase* it. Hence a two-vertex augmentation
  that keeps the independence number fixed at `7` is exactly a *critical* one.
- Restriction commutes with the unit-distance-graph construction: the unit-distance graph of a
  sub-configuration is the induced subgraph of the full unit-distance graph. This is what makes
  the finite threshold argument transfer to genuine planar unit-distance graphs.

## 5. What is *not* computed here

The evidence above is the combinatorial skeleton. The geometric input — the *existence* of an
actual planar two-point extension of a 27-point configuration that keeps the maximum
independent set at 7, and its *uniqueness up to isometry* — is not a finite check and is left
as the open geometric question (see `FUTURE_DIRECTIONS.md`).
