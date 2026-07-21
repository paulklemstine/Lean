# Computational Evidence

## Small-case calculations

For a retained leaf set `A`, every displayed split side in a restricted split system is a subset of `A`. Thus the universal state-space calculation gives:

| `|A|` | Maximum possible split sides in an arbitrary restricted split system, `2^|A|` |
|---:|---:|
| 0 | 1 |
| 1 | 2 |
| 2 | 4 |
| 3 | 8 |
| 4 | 16 |
| 5 | 32 |
| 6 | 64 |

These figures are upper bounds for arbitrary split systems, not exact counts of binary phylogenetic tree restrictions. Compatibility among tree splits makes the phylogenetic state space smaller.

For a single tree, the threshold predicate is exact: an `n`-leaf common agreement subtree exists on an ambient `N`-leaf set exactly when `n ≤ N`. For requested sizes `n ≥ 4`, selecting any four leaves from a common `n`-leaf restriction produces a common quartet.

## OEIS search results

No new integer sequence is asserted. The powerset counts above are the standard sequence `1, 2, 4, 8, 16, ...` (powers of two); assigning an OEIS identifier would add no evidence specific to phylogenetic compatibility.

## Counterexample hunt

The overlap condition in witness gluing cannot be removed. Take two disjoint singleton tree families and choose their trees to have different restrictions on the retained set. Each singleton family has a common restriction internally, but their union does not. This identifies overlap-connectedness as a genuine boundary condition.

The crude `2^|A|` split-side bound cannot be interpreted as an exact count for binary trees: arbitrary collections of subsets need not satisfy split compatibility. No counterexample was found to the stated restriction, heredity, gluing, or threshold-transfer claims; each is established for arbitrary finite split systems.

## Tables and structural observations

The useful computational reduction is not a large numerical search but a state-space compression:

1. restriction deletes all information outside `A`;
2. each surviving split side lies in the powerset of `A`;
3. overlap identifies independently chosen common-restriction witnesses;
4. a common restriction on at least four leaves descends to every selected quartet.

A quantitative reproduction of the paper's fourfold exponential bound requires a compatibility-sensitive count of binary tree restrictions, which is not supplied by the universal powerset table.
