# Computational Evidence — Extremal intersecting families of permutations

We study families of permutations of `{0, 1, …, n-1}` (elements of the symmetric
group `S_n`). Two permutations **agree** at position `i` when `σ(i) = τ(i)`.
A family is **t-intersecting** if any two members agree in at least `t` positions.
The permutation Complete Intersection question (Deza–Frankl 1977, Kupavskii 2022)
asks for the maximum size of such a family; the conjectured extremum is `(n-t)!`.

## 1. The fixed-point bridge (small-case verification)

Two permutations agree at `i` exactly when `σ⁻¹τ` fixes `i`, so the number of
agreements equals the number of fixed points of `σ⁻¹τ`.

Example in `S₃` (positions `0,1,2`):
- `σ = (0 1 2)` (cycle), `τ = (0 2 1)`. Then `σ⁻¹τ = (0 2 1)(0 2 1) = (0 1 2)`,
  a derangement (0 fixed points) — and indeed `σ, τ` disagree at every position.
- `σ = id`, `τ = (1 2)`. Then `σ⁻¹τ = (1 2)`, fixed point set `{0}` — and `σ, τ`
  agree exactly at position `0`.

The bridge holds in all checked cases; it is proved in full generality as
`agreements_eq_fixed`.

## 2. Size of the prefix-stabilizer family `fixPrefix t m`

`fixPrefix t m` is the set of permutations of `Fin (t+m)` fixing each of the
first `t` points. Predicted size: `m! = (n-t)!` with `n = t+m`.

| t | m | n=t+m | computed \|fixPrefix\| | m!  |
|---|---|-------|------------------------|-----|
| 1 | 2 | 3     | 2                      | 2   |
| 2 | 2 | 4     | 2                      | 2   |
| 3 | 0 | 3     | 1                      | 1   |
| 0 | 3 | 3     | 6                      | 6   |
| 2 | 3 | 5     | 6                      | 6   |

All rows match `m!` exactly (verified by brute-force enumeration with `#eval`
over the finite symmetric group). This is proved as `card_fixPrefix`.

## 3. t-intersection property

For any two members of `fixPrefix t m`, both fix positions `0,…,t-1`, so they
agree there: at least `t` common agreements. Brute-force check for `t=2, m=2`:
every pair of the two members agrees on `{0,1}` (2 positions) — matches the
`t = 2` lower bound. Proved as `fixPrefix_tIntersecting`.

## 4. Counterexample hunt

We searched for a t-intersecting family beating `(n-t)!` for small `n` by
enumerating maximal intersecting families in `S₃, S₄`. For `t = 1` the maximum
is `(n-1)!` (attained, never exceeded), consistent with Deza–Frankl. No
counterexample to the `(n-t)!` upper bound was found in the searched range; the
upper bound itself is the deep open half and is left as a future direction.

## 5. OEIS

The extremal sizes `(n-t)!` are shifted factorials (OEIS A000142 `n!`:
1, 1, 2, 6, 24, 120, …), which the table above reproduces.

**Conclusion.** All finite computations agree with the theorems formalized in
`PermutationAgreement.lean` and `PermutationCompleteIntersection.lean`.
