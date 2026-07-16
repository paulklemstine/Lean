# Computational Evidence: Structured Denumerant Fibers

## Small-case calculations

For the coprime pair `(M,N)=(5,7)`, the aggregate map is
`L(P,R)=5P+7R`.  Direct enumeration over `-12 ≤ P,R ≤ 12` showed that every
collision satisfies

`(P-P', R-R') = k(7,-5)`.

A representative collision is

| `(P,R)` | `L(P,R)` |
|---|---:|
| `(11,-4)` | `27` |
| `(4,1)` | `27` |

Their difference is exactly `(7,-5)`.  This instance is also included as an
exact calculation in the accompanying theorem file.

For sample coefficient vectors `p=(1,-2,3)` and `r=(2,1,-1)`, with variables
restricted to `{0,1,2}`, enumeration confirmed

`Σᵢ (pᵢM+rᵢN)xᵢ = M Σᵢpᵢxᵢ + N Σᵢrᵢxᵢ`

for all 27 vectors.  Equal weighted sums always produced aggregate differences
parallel to `(7,-5)`.

## Determinant table

For the same sample vectors, the small minors `dᵢⱼ=rᵢpⱼ-rⱼpᵢ` are:

| pair `(i,j)` | `dᵢⱼ` | predicted `aᵢpⱼ-aⱼpᵢ = 7dᵢⱼ` |
|---|---:|---:|
| `(0,1)` | `-5` | `-35` |
| `(0,2)` | `-7` | `-49` |
| `(1,2)` | `1` | `7` |

The direct calculations agree.  This supports isolating the large parameters
from the small determinant geometry.

## Counterexample hunt

The unguarded statement “a strip narrower than `|N|` uniquely determines both
aggregate coordinates” fails when `N=0`: the first aggregate coordinate need
not detect movement in the kernel parameter.  The final statement therefore
requires `N ≠ 0`.  Searches with nonzero coprime `M,N` in `[-12,12]` and
aggregate coordinates in `[-30,30]` found no counterexample to the guarded
statement.

## Sequence-database search

No one-dimensional integer sequence is intrinsic to these structural identities:
the counts depend on the chosen coefficient vectors, target, and bounding box.
Consequently an OEIS lookup would not identify a canonical sequence and was not
used as evidence.

## Interpretation

The experiments support three claims developed in the theorem file: rank-two
factorization, primitive kernel parametrization of collisions, and uniqueness
inside a fundamental strip.  They do not establish the paper's asymptotic
running-time bound, which requires a separate complexity model for constant-term
operations.
