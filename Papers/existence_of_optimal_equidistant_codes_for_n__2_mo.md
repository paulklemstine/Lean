# Computational Evidence — Equidistant-code BIBD family and its Pell obstruction

Proposed family (symmetric `2-(v,k,λ)` design equivalent to an optimal
equidistant code with `n ≡ 2 mod 4`):

```
v = 12u² + 8u + 2,   k = 6u² + u,   λ = k(k−1)/(v−1).
```

## 1. λ collapses to a polynomial

Factorizations: `v−1 = (2u+1)(6u+1)` and `k(k−1) = u(6u+1)(2u+1)(3u−1)`.
Cancellation gives the polynomial index and design order:

```
λ = 3u² − u,    order = k − λ = u(3u+2).
```

Small cases (all integers, confirming exact divisibility):

| u | v   | k   | λ   | order = k−λ |
|---|-----|-----|-----|-------------|
| 0 | 2   | 0   | 0   | 0           |
| 1 | 22  | 7   | 2   | 5           |
| 2 | 66  | 26  | 10  | 16          |
| 3 | 134 | 57  | 24  | 33          |
| 4 | 226 | 100 | 44  | 56          |
| 5 | 342 | 155 | 70  | 85          |

## 2. Parity

`v = 4(3u²+2u) + 2`, so `v ≡ 2 (mod 4)`; every point count is even. By the
Bruck–Ryser–Chowla theorem, a symmetric design on an even number of points
requires the order `k−λ` to be a perfect square.

## 3. When is the order a perfect square? (counterexample hunt → Pell)

Identity: `(3u+1)² = 3·u(3u+2) + 1`. Hence `u(3u+2)=m²` iff `(3u+1)²−3m²=1`,
the Pell equation `x²−3y²=1` with `x=3u+1`.

Brute force over `0 ≤ u ≤ 500` finds the order to be a perfect square exactly at

```
u ∈ {0, 2, 32, 450}.
```

These correspond to Pell solutions `(x,y) = (1,0), (7,4), (97,56), (1351,780)`
(the sub-sequence of `x²−3y²=1` with `x ≡ 1 mod 3`), satisfying
`x_{n+1} = 14 x_n − x_{n−1}` and `u_{n+1} = 14u_n − u_{n−1} + 4`.

**Counterexample to the bold existence claim:** `u = 1` gives order `5`, not a
perfect square, so the symmetric `2-(22,7,2)` design — and the corresponding
optimal equidistant code — does not exist.

## 4. OEIS

The admissible `u`-sequence `0, 2, 32, 450, 6272, …` is the interleaved solution
of a Pell recurrence (`a(n)=14a(n−1)−a(n−2)+4`); the associated Pell `y`-values
`0, 4, 56, 780, …` are `4×` the standard `x²−3y²=1` denominators. The point of
the file is the structural Pell characterization rather than a specific OEIS ID.

## Conclusion

The proposed family is **not** universally realizable. Its admissible members are
sparse and Pell-indexed; the correct characterization is Diophantine, and all of
the above is formalized in `EquidistantBIBDPellObstruction.lean`.
