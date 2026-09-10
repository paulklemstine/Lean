# Computational evidence: products of snakes and induced paths in grids

All numbers below were obtained by exhaustive depth-first search (no heuristics, no
pruning beyond the induced-path constraint itself).  They are *evidence*, not verified
claims: the verified statements are exactly the Lean theorems in
`Catalog/Algebra/SnakeProduct/`.

## 1. Snake-in-the-box numbers of small cubes

Exhaustive search over `Q_n` (induced paths starting at `0`, which is WLOG by vertex
transitivity):

| `n`    | 1 | 2 | 3 | 4 | 5 |
|--------|---|---|---|---|---|
| `s(n)` | 1 | 2 | 4 | 7 | 13 |

`s(0)=0`, `s(1)=1`, `s(2)=2` are proved in Lean (`SnakeProduct.snakeNum_zero`,
`snakeNum_one`, `snakeNum_two`).  The rest is search output only.

Sanity check of the conjecture on these values (the conjecture with `C = 1` is
equivalent to `s(m+n) ≥ s(m)·s(n) + 1`):

| `(m,n)` | `s(m)s(n)+1` | `s(m+n)` | holds? |
|---------|--------------|----------|--------|
| (1,1)   | 2            | 2        | yes (equality) |
| (2,2)   | 5            | 7        | yes |
| (2,3)   | 9            | 13       | yes |

So no counterexample to the conjecture itself is visible at small size, and the smallest
instance `(1,1)` shows `C = 0` is impossible: `(1+1)(1+1) = 4 > 2 = s(2)`.  This is the
content of the Lean theorem `SnakeProduct.conjecture_constant_ge_one`.

## 2. The real question: induced paths in the product grid

If `A` is the vertex set of a snake of length `L` in `Q_m` and `B` that of a snake of
length `K` in `Q_n`, then `A × B ⊆ Q_{m+n}` induces exactly the grid
`P_{L+1} □ P_{K+1}` (Lean: `hdist_sum_elim` plus the distance dichotomy along a snake).
Hence *every* product-based construction is an induced path in a grid.  Exhaustive
search for the longest induced path in the `a × b` grid (length = number of edges,
`verts = length + 1`):

| `a × b` | max length | vertices | `a·b` | density | comb `⌊L/2⌋(K+2)+K` |
|---------|-----------|----------|-------|---------|----------------------|
| 2×2 | 2  | 3  | 4  | 0.750 | 1  |
| 3×3 | 6  | 7  | 9  | 0.778 | 6  |
| 4×4 | 10 | 11 | 16 | 0.688 | 8  |
| 5×5 | 16 | 17 | 25 | 0.680 | 16 |
| 6×6 | 23 | 24 | 36 | 0.667 | 19 |
| 4×6 | 16 | 17 | 24 | 0.708 | 12 |
| 5×9 | 29 | 30 | 45 | 0.667 | 29 |
| 4×9 | 24 | 25 | 36 | 0.694 | 24 |

Observations.

* **The density never reaches `1`, and appears to settle near `2/3`.**  The conjectured
  bound `(L+1)(K+1) − C(L+K)` asks for density `1 − o(1)`; the data says this is
  impossible inside a product.  The Lean theorems `product_support_card_bound` and
  `product_mechanism_fails` prove the (weaker but rigorous) cap `3/4`, which already
  refutes the mechanism.
* The `2×2`-square argument behind the `3/4` cap is visible in every optimum: no
  optimal set ever contains four corners of a unit square.
* The comb (proved correct in Lean) has asymptotic density `(K+2)/(2(K+1))`
  (`combLen_density`): `3/4` when `K = 1`, `2/3` when `K = 2`, tending to `1/2`, and is *exactly optimal* in the
  narrow cases `3×3`, `5×5`, `5×9`, `4×9` of the table, while it loses by ~25 % in the
  large square cases.  The truth for large `L, K` therefore lies between `1/2` and `3/4`,
  with the data pointing at `2/3`.

Optimal `6×6` configuration found (`#` = used):

```
#.###.
#.#.##
#.##.#
#..#.#
#.##.#
###.##
```

24 of 36 cells = `2/3`; note the absence of any full `2×2` block.

Vertex counts of maximum induced paths in the `n × n` grid for `n = 2..6`:
`3, 7, 11, 17, 24`.  No OEIS lookup was performed (no network access in this
environment), so no identifier is asserted.

## 3. Counterexample hunt

* Against the **conjecture itself** (unrestricted snakes in `Q_{m+n}`): none found; all
  small instances hold with `C = 1`, and asymptotically the conjecture is consistent
  because `λ² < λ` for the snake density constant `λ = lim s(n)/2^n < 1`.
* Against the **mechanism** ("products plus bounded chord repair"): refuted, both
  numerically (densities above) and formally (`product_mechanism_fails`).  Any repair
  scheme must move vertices *off* the product set `A × B`.
