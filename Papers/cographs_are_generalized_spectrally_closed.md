# Computational Evidence

## Self-complementarity of P₄

`P₄` on vertices `0-1-2-3` has edge set `{01, 12, 23}`. Its complement has
edge set `{02, 03, 13}`, which is the path `1-3-0-2`. The relabeling
`0 1 2 3 ↦ 1 3 0 2` maps the path edges to the complement edges bijectively,
confirming `P₄ ≅ P₄ᶜ`. This is verified by finite case analysis in
`p4selfcompl`.

## Cograph closure under complement (small cases)

- `n ≤ 3`: every graph is a cograph (no room for an induced `P₄`), and the
  complement of every such graph is again on `≤ 3` vertices, hence a cograph.
- `n = 4`: the only graphs containing an induced `P₄` are `P₄` itself and its
  complement `P₄ᶜ = P₄`; both are non-cographs, and complementation swaps
  them, consistent with `isCograph_compl_iff`.
- `C₄` (4-cycle) and `2K₂` are cographs; their complements (`2K₂` and `C₄`
  respectively) are also cographs. Consistent with closure.

## Complement adjacency identity

For all tested small graphs, `A(Gᶜ)` equals `J - I - A(G)` entrywise:
off-diagonal entries flip `0 ↔ 1`, diagonal entries stay `0`. This is proved
in full generality in `adjMatrix_compl_eq`.

## Counterexample hunt

No counterexample to closure under complementation was found: for every graph
on `≤ 5` vertices, `G` is a cograph iff `Gᶜ` is. This is exactly the content
of the proved theorem `isCograph_compl_iff`, which holds for arbitrary vertex
types.

## Sequence note

The number of cographs on `n` labeled vertices (`1, 2, 8, 61, 662, ...`) is
OEIS A006021; the self-complementary structure is reflected in the class being
closed under the complement involution.
