# Computational Evidence

Small-case checks supporting the width-driven Betti bound and the cell counts.

## 1. Activation-pattern counts `∏ᵢ 2^{wᵢ} = 2^{Σ wᵢ}`

| widths `(w₁,…,w_L)` | `∏ 2^{wᵢ}` | `2^{Σ wᵢ}` |
|---------------------|-----------|-----------|
| `(1)`               | 2         | 2         |
| `(2)`               | 4         | 4         |
| `(1,1)`             | 4         | 4         |
| `(2,3)`             | `4·8 = 32`| `2^5 = 32`|
| `(2,2,2)`           | 64        | `2^6 = 64`|

The two columns agree in every case, matching `activationPattern_eq_two_pow_sum`.

## 2. Sign-cell counts `3^m` for an `m`-hyperplane layer

| `m` | `3^m` |
|-----|-------|
| 0   | 1     |
| 1   | 3     |
| 2   | 9     |
| 3   | 27    |

A single hyperplane (`m = 1`) yields the three cells `{-, 0, +}` (two open
half-spaces and the hyperplane itself), confirming `card_signCells`.

## 3. Betti bound sanity checks

For the subquotient bound `dim(Z/B) ≤ dim Z ≤ dim C`:

* If `C₁` has dimension 3 (three cells), then no matter which boundary/cycle
  configuration occurs, `dim H ≤ 3`. E.g. with `Z = C₁` and `B = 0` we get the
  extreme `dim H = 3`; with `B = Z` we get `dim H = 0`. Both respect the bound.
* The exact identity `β + rank B = rank Z` was checked against these extremes:
  `3 + 0 = 3` and `0 + 3 = 3`.

## 4. Width bound is genuinely loose (motivating the bigraded conjecture)

For a single hidden layer of width `w`, the total bound gives `β ≤ 2^{w}`, while
the number of *bounded* faces of a generic `w`-hyperplane arrangement in the
plane is only `C(w-1, 2)`. For `w = 5`: total bound `32` versus `6` bounded
faces. The gap grows exponentially, which is exactly the phenomenon Conjecture 1
in `FUTURE_DIRECTIONS.md` seeks to close with a per-layer factorisation.

## Counterexample hunt

No counterexample to any proved statement was found. The subquotient bound and
the `Fintype.card` product identity are dimension-free and hold in every finite
case tested. The only "failure" is the deliberate looseness of the total-count
bound versus the true face count, which is expected and motivates the bigraded
refinement rather than contradicting any theorem.
