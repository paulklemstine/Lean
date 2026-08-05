# Computational evidence

All numerics below were used only to *find* the configurations; every statement that is
claimed as a result is proved in Lean (`Catalog/Shared/GilbertLattice*.lean`), with no
`sorry` and no extra axioms.

## 1. The diagonal cut and `R_full = √5`

Cells are split by `c₁ ≤ c₂` (upper) versus `c₁ > c₂` (lower); upper cells put their
point at the top-left corner, lower cells at the bottom-right corner.  Exhaustive
enumeration of all pairs (upper cell, lower cell) with coordinates in `[-6, 6]` gives

| minimal squared crossing distance | attained at |
|---|---|
| `5` | e.g. upper `(-6,-6)` / lower `(-5,-6)` |

matching the integer optimisation `min {u² + v² : u, v ∈ ℤ, v ≥ u + 3} = 5`
(attained at `(u,v) = (-1,2)` and `(-2,1)`; the *real* optimum would be `9/2`).
Since two points of edge-adjacent cells are always at distance `≤ √5`, this closes the
previously known gap `√17/2 ≤ R_full ≤ √5` to the exact value `R_full = √5`
(`GilbertLattice.Rfull_eq_sqrt_five`).

## 2. Search for a fully connected placement below radius `1`

For a `P × Q`-periodic placement, the radius needed to connect all points was estimated
by building the point set on a window of `(2W+1)²` cells and running Kruskal's algorithm
until all *interior* cells lie in one component (using boundary points only as helpers).
Sanity checks: the centred placement returns `1.0`, the horizontal line placement (which
percolates at `1/2`) returns `2.0` for full connectivity — both as expected.

Simulated annealing plus coordinate descent over the offsets gave:

| period `P × Q` | best radius found |
|---|---|
| `1 × 1` (lattice) | `1.0000` |
| `2 × 2` | `0.78768` |
| `2 × 4` | `0.8818` |
| `4 × 2` | `0.8442` |
| `3 × 3` | `0.8456` |
| `4 × 4` | `0.8542` |

Rounding the `2 × 2` optimum to quarters gives an exactly rational placement whose
critical radius is `√(5/8) = √10/4 ≈ 0.790569`, i.e. only `0.4 %` above the numerical
optimum:

```
(even, even) ↦ offset (1/2, 3/4)      point (i + 1/2, j + 3/4)
(even, odd ) ↦ offset (1/4, 1  )      point (i + 1/4, j + 1  )
(odd , even) ↦ offset (1/4, 1  )      point (i + 1/4, j + 1  )
(odd , odd ) ↦ offset (1  , 1/4)      point (i + 1  , j + 1/4)
```

Exact (rational) enumeration of all displacements `(Δi, Δj)` with `|Δi|, |Δj| ≤ 2` shows
that the edges of squared length `≤ 5/8` are exactly

| from | to | squared length |
|---|---|---|
| `(even, even)` | `(i+1, j)` | `5/8` |
| `(even, even)` | `(i, j-1)` | `5/8` |
| `(even, even)` | `(i-1, j+1)` | `1/2` |
| `(odd, odd)`  | `(i, j-1)` | `5/8` |
| `(odd, odd)`  | `(i+1, j)` | `5/8` |

and a breadth-first search confirms that these five families connect every cell to its
right neighbour and to its neighbour above.  Both facts are what the Lean file
`GilbertLatticeZigzag.lean` proves (the squared lengths `5/8` and `1/2` are verified by
`ring`, the chains by explicit paths), giving `R_conn ≤ √10/4 < 1`.

Note that no *lattice* placement can beat `1` (a lattice of covolume `1` has
`max(λ₁, λ₂) ≥ 1`, with equality for `ℤ²`); the Lean statement
`GilbertLattice.alignedConfig_connected_iff` proves the corresponding exact threshold
`1` for the aligned (constant-offset) family.  So beating `1` requires a genuinely
non-lattice placement, as the zig-zag placement is.

## 3. The spectrum of squared edge lengths

For aligned placements the squared edge lengths are the integers `a² + b²`, `(a,b) ≠ 0`:

```
1, 2, 4, 5, 8, 9, 10, 13, 16, 17, 18, 20, 25, 26, 29, 32, 34, 36, 37, 40, …
```

This is OEIS A001481 (numbers that are the sum of two squares) with `0` removed.  The
missing values `3, 6, 7, 11, 12, 14, 15, 19, 21, 22, 23, 24, …` are exactly those with a
prime factor `≡ 3 (mod 4)` appearing to an odd power (OEIS A022544).  Small-case check
for primes: `2, 5, 13, 17, 29, 37` occur; `3, 7, 11, 19, 23, 31` do not — the pattern
`p % 4 ≠ 3` of Fermat's two-square theorem.  These observations are proved in
`GilbertLatticeSumTwoSquares.lean`
(`latticeSpectrum_eq_sums_of_two_squares`, `prime_mem_latticeSpectrum_iff`,
`latticeSpectrum_iff_factorization`, `latticeSpectrum_mul`,
`latticeSpectrum_eq_gaussianInt_norms`).
