# Computational Evidence — Certified Novelty Detection

This note records the small-case evidence that motivated the formal development in
`EmbeddingSpace.lean`, `Packing.lean`, and `FibonacciNoveltyStream.lean`.

## 1. The novelty function is the min-distance (sanity checks)

For a catalog `C ⊆ ℝ` with the usual metric and `novelty C x = min_{c∈C} |x − c|`:

| `C`            | `x`  | `novelty C x` |
|----------------|------|---------------|
| `{0, 3, 10}`   | `4`  | `1`           |
| `{0, 3, 10}`   | `3`  | `0` (in `C`)  |
| `{0, 3, 10}`   | `7`  | `3`           |

These confirm: `novelty = 0 ⇔ x` already in catalog (soundness), and `novelty` is
`1`-Lipschitz (`|novelty 4 − novelty 5| = |1 − 2| = 1 ≤ |4 − 5|`).

## 2. Packing ≤ covering (novelty budget), worked example

Embed into the interval `[0, 1]` and cut it into the `m` cells
`[k/m, (k+1)/m)`.  Each cell has diameter `1/m < ε` once `m > 1/ε`.  Then any
`ε`-separated catalog has at most `m` points — e.g. with `ε = 1/4`, at most `4` cells of
width `< 1/4`, so at most `4` certifiably-novel points fit.  This is exactly
`Separated.card_le_of_cells`.

## 3. The Carmichael primitive-divisor novelty stream

`carPrime p` is a primitive prime divisor of the Fibonacci number `F p`.  Computed
primitive prime divisors of `F p` for prime indices `p ≥ 3`:

| `p`  | `F p`   | primitive prime divisor(s) | `carPrime p` (a choice) |
|------|---------|----------------------------|-------------------------|
| `3`  | `2`     | `2`                        | `2`                     |
| `5`  | `5`     | `5`                        | `5`                     |
| `7`  | `13`    | `13`                       | `13`                    |
| `11` | `89`    | `89`                       | `89`                    |
| `13` | `233`   | `233`                      | `233`                   |
| `17` | `1597`  | `1597`                     | `1597`                  |
| `19` | `4181`  | `37, 113`                  | `37` or `113`           |
| `23` | `28657` | `28657`                    | `28657`                 |

**Key observation (distinctness):** the chosen primes
`2, 5, 13, 89, 233, 1597, …` are pairwise distinct.  This is forced by *primitivity*: a
prime that is primitive for `F p` divides no `F k` with `k < p`, so it cannot also be the
primitive prime of a larger index.  Distinct naturals embed to reals at distance `≥ 1`, so
the embedded catalog `{2, 5, 13, 89, 233, …}` is `1`-separated of unbounded size — an
**unbounded novelty budget** (`unbounded_novelty_budget`).

## 4. Counterexample hunt

* *Is `novelty` Lipschitz with a constant `< 1`?*  No: with `C = {0}`,
  `novelty x = |x|`, and `|novelty 1 − novelty 0| = 1 = |1 − 0|`, so the constant `1` is
  sharp.  (Confirms `LipschitzWith 1`, not better.)
* *Does the packing bound need `ε > 0`?*  The formal proof revealed it does **not**: for
  `ε ≤ 0` the cell condition forces the cell map to be injective and the bound holds a
  fortiori.  The hypothesis was dropped (see Lab Notes in `Packing.lean`).
* *Could two distinct prime indices share a primitive prime?*  Searched all prime indices
  up to `23`; none collide, matching the primitivity proof.

## Sequence note

The sequence of primitive prime divisors of Fibonacci numbers is the subject of
Carmichael's primitive divisor theorem; our `carPrime` selects one primitive prime per
prime index `p ≥ 3`.  (We do not assert a specific OEIS identifier here, to avoid an
unverified reference.)
