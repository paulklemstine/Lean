# Computational Evidence — Skip Justification

The central result is a structural equivalence, not a numerical conjecture: assuming a term family has a minimum, “the minimum is attained by at least two terms” is equivalent to satisfaction of every bend equation obtained by deleting one term. Its proof is a direct witness transformation in both directions, so finite numerical sampling would not strengthen the universal argument.

A concrete sanity check is nevertheless included and machine-verified in `Catalog/Tropical/TropicalSchemesConnector.lean`: for the min-plus linear polynomial `min(0,x)`, the bend-equation locus is exactly `x = 0`.
