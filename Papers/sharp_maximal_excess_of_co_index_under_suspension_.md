# Computational Evidence: co-index of octahedral spheres under suspension

All claims below are backed by the verified development in `SuspensionCoindex.lean`.

## Small-case structure of the octahedral spheres `Oct n`

| `n` | vertices `2(n+1)` | top face size | `dim` | co-index (this model) |
|----:|------------------:|--------------:|------:|----------------------:|
| 0   | 2                 | 1             | 0     | 0                     |
| 1   | 4                 | 2             | 1     | ≥ 1                   |
| 2   | 6                 | 3             | 2     | ≥ 2                   |
| 3   | 8                 | 4             | 3     | ≥ 3                   |

* Top face size and dimension: the "positive orthant" `{(i, true)}` is a face of size
  `n+1` (`Oct_face_full`), and no face exceeds `n+1` vertices (`Oct_face_card_le`),
  so `dim(Oct n) = n`.
* Co-index lower bound: the identity is an equivariant simplicial self-map, giving
  `HasCoindGe (Oct n) (Oct n)` (`coind_Oct_self`).

## Suspension raises dimension and co-index

* `Susp(Oct n)` has a face of size `n+2` (`Susp_face_full` on a top face of `Oct n`
  together with an apex), so `dim(Susp(Oct n)) = n+1`.
* There is an explicit equivariant simplicial map `Oct (n+1) → Susp(Oct n)`
  (`Susp_iso_Oct`), the combinatorial `Sⁿ⁺¹ ≅ S(Sⁿ)`.
* Consequently `HasCoindGe (Oct (n+1)) (Susp(Oct n))` (`coind_susp_Oct`), matching the
  topological value `coind(Sⁿ⁺¹) = n+1`.

## Counterexample hunt for the base case

We searched for an equivariant simplicial map `Oct n → Oct 0` with `n ≥ 1`. The face
`{(0,true),(1,true)}` of `Oct n` is forced onto a single vertex of `Oct 0`, after
which equivariance forces an antipodal pair into the image of a genuine face — a
contradiction. No such map exists; `borsuk_ulam_base` records this, so the co-index of
`S⁰` is exactly `0` and the co-index cannot be "faked" by a dimension-dropping map.

## The generic `+1` versus the conjectured large jump

The verified suspension lemma gives excess exactly `+1`. A brute-force expectation
that a single suspension could jump the co-index by more than one is *not* supported
by any construction found here for the octahedral tower — consistent with the
octahedral spheres sitting on the diagonal `coind = dim`. The large-jump phenomenon
(excess `d − c` with `c < d`) therefore requires genuinely different complexes, which
is exactly the content of Future Direction 1.
