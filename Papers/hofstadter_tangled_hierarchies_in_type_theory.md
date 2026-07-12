# Computational Evidence — Tangled Hierarchies

Concise numerical sanity checks for the claims formalized in
`Catalog/Logic/TangledHierarchies.lean`.

## 1. The level ladder `(ℕ, <)` carries no two-cycle

We searched all pairs `(x, y)` with `x, y ≤ 200` for a tangle
`x < y ∧ y < x`.

- Pairs tested: `201 × 201 = 40 401`.
- Tangles found: **0**.

This matches `universeLevels_not_tangled`: strict `<` on `ℕ` is asymmetric, so no
level is simultaneously above and below another.

## 2. Adjacency `refersAdjacent n m := (m = n+1) ∨ (n = m+1)` is tangled

- `refersAdjacent 0 1` : `1 = 0 + 1` — true.
- `refersAdjacent 1 0` : `1 = 0 + 1` — true.

So `(0, 1)` is an explicit two-cycle. More generally every consecutive pair
`(n, n+1)` is a two-cycle, giving infinitely many tangles on the same carrier `ℕ`
whose order relation `<` had **none**. The tangle is a property of the *reference*
graph, not of the level order beneath it.

## 3. No consistent grading of a tangle

For the two-cycle `(0,1)` in `refersAdjacent`, a strictly increasing rank `f : ℕ → ℕ`
would need `f 0 < f 1` and `f 1 < f 0` simultaneously — impossible for natural
numbers. Brute check over all `f` with values in `{0,…,9}` restricted to
`{0,1}` (100 candidate assignments): **0** satisfy both inequalities. This matches
`tangled_has_no_grading`.

## 4. The ultimate tangle (Cantor diagonal)

For a candidate "reflective universe" on a finite carrier `Fin n`, completeness of
`decode : Fin n → Set (Fin n)` would require a surjection onto `2^n` subsets from
only `n` codes.

| n | codes (n) | subsets (2^n) | surjection possible? |
|---|-----------|---------------|----------------------|
| 1 | 1 | 2 | no |
| 2 | 2 | 4 | no |
| 3 | 3 | 8 | no |
| 4 | 4 | 16 | no |

`n < 2^n` always, so no finite reflective universe exists; the diagonal argument
`no_surjective_to_powerset` extends this to arbitrary carriers, giving
`no_reflectiveUniverse`.

## OEIS note
The counts `2^n` (subsets) are A000079; the strict inequality `n < 2^n` underlies the
impossibility across all `n`. No new sequence is introduced.
