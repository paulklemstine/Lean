# Computational Evidence

## Small-case calculations

The first decisive collision occurs at order six.

| Object | Order | Prime ledger | Multiplication |
|---|---:|---|---|
| cyclic group `Z/6Z` | 6 | `[2, 3]` | commutative |
| symmetric group `S_3` | 6 | `[2, 3]` | noncommutative |

For `S_3`, let `a = (0 1)` and `b = (1 2)`. Their products differ: one sends `0` through the path determined by `b` then `a`, while the reverse product sends it through `a` then `b`. Thus the common atomic number and prime ledger do not determine commutativity.

A second calculation is symbolic rather than enumerative. If factor orders are `d_1, ..., d_r`, repeated use of the finite quotient product formula gives

`|G| = d_1 · ... · d_r`.

Consequently, two groups with literally the same multiset of composition factors, including multiplicity, necessarily have the same order. The proposed use of “isotope” for groups with the same composition factors but different orders is therefore inconsistent unless multiplicities are discarded or “same” is weakened.

## OEIS search results

No sequence claim is needed for the obstruction, so no OEIS identification is relevant. The evidence concerns a structural collision between invariants rather than a numerical sequence.

## Counterexample hunt

The universal claim tested was: equal atomic number and equal prime-factor ledger determine multiplication-sensitive properties. The pair `Z/6Z` and `S_3` is a counterexample. It is representative because both groups have the same two prime composition-factor orders, while the nontrivial semidirect action in `S_3` is absent from the cyclic group.

The stronger phrase “same composition factors but different orders” was also tested abstractly. It has no examples when composition factors are counted with multiplicity, because their orders multiply to the group order.

## Scope of the evidence

This evidence does not enumerate all groups of order at most 100. Instead it targets the earliest possible structural failure of the proposed organizing law. A complete census would add data, but it cannot repair a universal classification rule already contradicted at order six.
