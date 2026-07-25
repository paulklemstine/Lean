# Computational Evidence

## Small-case calculations

The local graph specialization laws were checked on representative connected weighted signatures.  A signature is listed as `(vertices, edges, total weight, legs)` and its genus is `weight + edges + 1 - vertices`.

| Initial signature | Contraction | Result | Initial genus | Result genus |
|---|---|---:|---:|---:|
| `(2,1,0,0)` | non-loop | `(1,0,0,0)` | 0 | 0 |
| `(3,3,0,0)` | non-loop | `(2,2,0,0)` | 1 | 1 |
| `(2,2,1,1)` | non-loop | `(1,1,1,1)` | 2 | 2 |
| `(1,1,0,0)` | loop | `(1,0,1,0)` | 1 | 1 |
| `(2,3,2,4)` | loop | `(2,2,3,4)` | 4 | 4 |

The two mechanisms are complementary.  A non-loop contraction decreases both edge and vertex counts by one.  A loop contraction decreases the edge count by one and increases total vertex weight by one.  Consequently the genus expression is unchanged in both cases.

Finite incidence tables of ranks zero through four were also examined.  Under a bijection between divisors and rays, elementwise transport preserved cardinality, inclusion, union, intersection, disjointness, and links.  Deliberately replacing the bijection by a non-injective map collapsed cardinality and showed that injectivity is essential for codimension preservation.

## Sequence-database search

No integer sequence is intrinsic to the claims studied here.  The relevant quantities are structural invariants of arbitrary weighted graphs and finite incidence systems, so an OEIS identifier would not provide meaningful evidence.

## Counterexample hunt

The unguarded assertion that an incidence correspondence alone constructs a global toric variety fails conceptually: incidence data determine a face poset but contain neither integral lattices, monomial transition maps, nor a global fan.  The tested and proved statement was therefore restricted to the strongest consequence supported by the data: an order isomorphism of face posets, dual complexes, links, and codimensions.

Within that guarded statement, exhaustive finite-set reasoning exposes two necessary assumptions.  Without injectivity, distinct boundary divisors may map to one ray; without incidence compatibility, a transported boundary face need not be a tropical face.  Both assumptions are retained in the atlas criterion.
