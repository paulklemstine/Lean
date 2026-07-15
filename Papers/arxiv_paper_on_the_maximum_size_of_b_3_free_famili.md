# Computational Evidence

## Small cases

For a Boolean lattice B_d, the canonical maximal chain has ranks

| d | ranks on the chain | number of distinct ranks required |
|---:|:-------------------|:----------------------------------|
| 0 | 0 | 1 |
| 1 | 0, 1 | 2 |
| 2 | 0, 1, 2 | 3 |
| 3 | 0, 1, 2, 3 | 4 |
| 4 | 0, 1, 2, 3, 4 | 5 |

Thus a weak B₃ copy necessarily uses four distinct cardinalities along the image of this chain. Any family confined to ranks r, r+1, and r+2 fails this necessary condition.

For ambient dimensions n = 3, 4, 5, and 6, the sizes of the three ranks centered as closely as possible around n/2 are respectively 7, 14, 25, and 50. These are baseline constructions; the rank argument certifies their weak and strong B₃-freeness whenever the selected ranks are consecutive.

## Sequence identification

The individual layer sizes are the binomial coefficients, the rows of Pascal's triangle (OEIS A007318 when read by rows). The sum of three selected consecutive layers is therefore
`binom(n,r) + binom(n,r+1) + binom(n,r+2)`.

## Counterexample hunt

The universal rank-window claim was checked against its boundary cases. A window of d+1 ranks is not generally safe: B_d itself occupies exactly ranks 0 through d and contains a weak B_d copy via the identity map. A window of d ranks excludes the canonical chain because d strict inclusions require a cardinality gain of at least d. No counterexample survives this rank inequality.

## Structural table

| Construction | ranks used | weak B₃-free by rank? | strong B₃-free by rank? |
|:-------------|:-----------|:----------------------|:------------------------|
| one layer | 1 | yes | yes |
| two consecutive layers | 2 | yes | yes |
| three consecutive layers | 3 | yes | yes |
| four consecutive layers | 4 | not certified | not certified |
| full B₃ | 4 | no | no |

The computation is deliberately secondary: the general result follows from a maximal-chain inequality rather than finite enumeration.
