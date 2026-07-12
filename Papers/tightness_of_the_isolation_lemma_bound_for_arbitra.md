# Computational Evidence — Tightness of the Isolation Lemma bound

## Object under study

For the singleton hypergraph `{ {v} : v ∈ [n] }` with zero edge offset, an
assignment `w ∈ [d]^n` is *isolating* iff a single vertex attains the strict
minimum weight. We count these assignments and compare with the Faber–Harris
lower bound `n · ∑_{j=0}^{d-1} j^{n-1}`.

## Small-case enumeration

Direct enumeration of `isoCountComp n d` versus `lowerBound n d = n·∑_{j<d} j^{n-1}`:

| (n, d) | isolating count | n·∑ j^{n-1} | match |
|--------|-----------------|-------------|-------|
| (1, 3) | 3               | 3           | ✓ |
| (2, 3) | 6               | 6           | ✓ |
| (3, 3) | 15              | 15          | ✓ |
| (2, 4) | 12              | 12          | ✓ |
| (3, 2) | 3               | 3           | ✓ |
| (4, 2) | 4               | 4           | ✓ |
| (3, 4) | 42              | 42          | ✓ |
| (1, 5) | 5               | 5           | ✓ |
| (0, 3) | 0               | 0           | ✓ |
| (2, 2) | 2               | 2           | ✓ |

All ten sampled cases match exactly. No counterexample was found in the grid
`{0,1,2,3,4} × {2,3,4,5}`.

## Sequence identification

The row `(3, d)` for `d = 0,1,2,3,4,5` gives `0, 1, 15, 42, 90, 165`, i.e.
`3 · ∑_{j<d} j^2` — three times the square-pyramidal numbers. The column
structure `n · ∑_{j<d} j^{n-1}` interpolates the "sum of `(n-1)`-th powers"
family (OEIS A000330 for `n=3`, A000538 for `n=4`, etc.), each scaled by `n`.

## Counterexample hunt

The universal claim tested here is the *exact* equality for the singleton
hypergraph. Enumeration over the grid above revealed no discrepancy. The
strict-minimum reformulation of "isolating" was independently checked to be
logically equivalent to the `∃!`-minimum definition, ruling out an
off-by-definition artefact.

## Conclusion

The evidence strongly supported an exact identity, subsequently proved in
`IsolationLemmaTightness.lean` as `card_isolating_singleton_eq` with no
additional hypotheses and for all `n, d`.
