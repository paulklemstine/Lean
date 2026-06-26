# Computational Evidence — Transversal Orderings and Antipodal Symmetry

The formal claims of this cycle are structural identities over an arbitrary real
vector / normed space, so they are verified directly in Lean rather than by
numerical sampling. The small-case sanity checks below motivated the formal
statements.

## 1. Orientation reversal reverses order (small case)
Take three points on the real line at parameters `t = (0, 1, 2)` for sets
`S_0, S_1, S_2`. The directed line meets them in order `0 ≺ 1 ≺ 2`. Reversing the
orientation negates parameters to `(0, -1, -2)`, giving order `2 ≺ 1 ≺ 0` — the
exact reverse. This is the pattern captured by `geomPerm_reverse`.

| parameters     | induced order |
|----------------|---------------|
| (0, 1, 2)      | 0, 1, 2       |
| (0, -1, -2)    | 2, 1, 0       |

Reversing twice returns `(0,1,2)`: the involution property (`antipode_involutive`,
`reverse_reverse_point`).

## 2. Antipode fixed-point-free check
On the unit circle `S^1`, no unit vector `x` satisfies `x = -x` (that forces
`2x = 0`, i.e. `x = 0`, which is not on the sphere). Sampling
`x = (cos θ, sin θ)` for `θ ∈ {0, π/4, π/2, ...}` never yields `x = -x`. This is
`antipode_ne`.

## 3. Disjointness ⇒ distinct parameters
If `S_i` are pairwise disjoint and the line meets `S_i` at `t_i`, then `t_i = t_j`
would place the single point `base + t_i·dir` in both `S_i` and `S_j`,
contradicting disjointness. Verified abstractly as
`params_injective_of_pairwise_disjoint`; the `n = 2` case is the minimal witness.

## 4. Dimension/sphere bookkeeping (motivating Conjecture 1 & 4)
The Cheong–Goaoc–Holmsen construction uses `3n` ambient dimensions to realize an
`S^{n-1}` transversal space — three coordinates per antipodal `S^0` factor,
`(S^0)^{*n}` joining to `S^{n-1}`. The reduced homology `H̃_{n-1}(S^{n-1}) = ℤ`
is nonzero, which is what disproves the original homology-vanishing conjecture.

All four observations are reflected by `sorry`-free Lean theorems; no
counterexamples were found to the formalized statements.
