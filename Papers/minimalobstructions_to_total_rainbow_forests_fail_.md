# Computational Evidence

## Object under study

For two matroid rank functions `r₁, r₂` on a finite ground set `E` (the edge set of an
edge-coloured graph), the **Edmonds intersection objective** is

    obj(A) = r₁(A) + r₂(E \ A),   A ⊆ E.

By Edmonds' Matroid Intersection Theorem, `min_A obj(A)` equals the maximum size of a total
rainbow forest (a common independent set of the graphic matroid `M₁` and the colour
partition matroid `M₂`).  The **Rainbow Forest Inequality (RFI)** at target `t` says
`obj(A) ≥ t` for all `A`.

The mission conjecture: a *minimal obstruction* fails RFI for a *unique* subset `A`.

## Reading "minimal obstruction" as edge-deletion minimality

`G` is an edge-minimal obstruction if RFI fails for `G` but holds for every single-edge
deletion `G - e` (rank of the deletion equals ambient rank on subsets of `E \ {e}`).

### Small-case calculation (ground set `E = {a, b}`, free matroids `r(A) = |A|`)

| A        | r₁(A) | r₂(Aᶜ) | obj(A) |
|----------|-------|--------|--------|
| ∅        | 0     | 2      | 2      |
| {a}      | 1     | 1      | 2      |
| {b}      | 1     | 1      | 2      |
| {a,b}    | 2     | 0      | 2      |

So `obj ≡ 2`.  For target `t = 3`, RFI fails for **every** subset (4 of them), immediately
contradicting the "unique failing subset" reading even before deletion.

### Deletion test

Delete `a`.  New ground set `{b}`, subsets `∅, {b}`:

| A     | r₁(A) | r₂(({b})\A) | value |
|-------|-------|-------------|-------|
| ∅     | 0     | 1           | 1     |
| {b}   | 1     | 0           | 1     |

Both values are `< 3`, so `G - a` **still fails** RFI.  By symmetry so does `G - b`.  The
obstruction is *not* repaired by any deletion — there is no edge-minimal obstruction.

## Counterexample hunt / structural finding

The deletion table is not an accident.  For any monotone `r₁, r₂` and any `A ⊆ E`, put
`A' = A \ {e} ⊆ E \ {e}`.  Then

    obj_{G-e}(A') = r₁(A\{e}) + r₂((E\{e}) \ A)  ≤  r₁(A) + r₂(E\A) = obj_G(A),

using monotonicity twice (`A\{e} ⊆ A` and `(E\{e})\A ⊆ E\A`).  Hence
`min obj_{G-e} ≤ min obj_G`: **RFI-failure can only propagate to deletions, never be
cured.**  Therefore an edge-minimal obstruction cannot exist.  This is proved formally as
`no_edge_minimal_obstruction`.

## OEIS

No integer sequence is central to the claim; the content is a monotonicity/structural
inequality rather than an enumeration, so an OEIS search is not applicable.

## Conclusion

The evidence points not to a uniqueness phenomenon but to a *collapse*: the certifying
subset of an RFI obstruction survives every edge deletion.  This motivated the formal
theorems in `Speculative/RainbowForestDeletion.lean`.
