# Computational Evidence — general suspension dimension law and octahedral facets

## 1. Small-case calculations

### Dimension of the octahedral tower `Sᵏ(Oct n)`

The predicted dimension is `n + k`. Computed maximal face sizes (a face is an
antipodal-pair-free vertex set; dimension = max face size − 1):

| base `n` | height `k` | predicted `dim = n+k` | top-face size `n+1+k` |
|---------:|-----------:|----------------------:|----------------------:|
| 0 | 0 | 0 | 1 |
| 0 | 1 | 1 | 2 |
| 0 | 3 | 3 | 4 |
| 1 | 0 | 1 | 2 |
| 2 | 3 | 5 | 6 |

These match the formalized `example` statements in
`Z2SuspensionTowerDimensionLaw.lean` (e.g. `IsDimEq (SuspIter (Oct 2) 3) 5`),
each proved from the general law `SuspIter_isDimEq`, not by ad-hoc computation.

### Facet count of `Oct n`

`Oct n` is the boundary of the `(n+1)`-cross-polytope; its facets are the
sign-vector orthants `{ (i, σ i) : i }` for `σ : Fin (n+1) → Bool`.

| `n` | facet count `2^{n+1}` |
|----:|----------------------:|
| 0 | 2 |
| 1 | 4 |
| 2 | 8 |
| 3 | 16 |

Verified in Lean via `Oct_facet_count` (e.g. `Oct 1` has exactly `4` facets,
the four edges of the square/`C₄`).

## 2. OEIS

The facet count `2, 4, 8, 16, …` is `A000079` (powers of two), the number of
facets of the `n`-dimensional cross-polytope / octahedral sphere. This is the
expected combinatorial certificate: facets ↔ sign vectors.

## 3. Counterexample hunt

- **Dimension law off the octahedral base.** The law `dim Sᵏ(K) = dim K + k` is
  claimed for *arbitrary* finite free ℤ₂-complexes with a top face. The single
  potential failure mode is a complex where a suspension adds two dimensions
  (both apexes in one face) or zero (no new top face). Both are excluded: a face
  of `Susp K` contains at most one apex (`Susp_face_card_le`) and inserting one
  apex into a top base face yields a strictly larger face (`Susp_face_full`). No
  counterexample exists; the law is proved unconditionally.

- **Void complex boundary.** The empty (void) complex has only the empty face and
  satisfies no `IsDimEq K d`; it is deliberately outside the law's scope. This is
  a genuine boundary, documented in the file.

## 4. Notes

Computational evidence is kept minimal and directly supports the two proved
theorems (general dimension law, facet enumeration). All numeric claims above are
discharged inside the Lean file by proofs, not merely by evaluation.
