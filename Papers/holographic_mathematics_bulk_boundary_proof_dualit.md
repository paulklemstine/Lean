# Computational Evidence

The main positive result is structural order duality, so it does not depend on numerical experimentation. Small finite cases are nevertheless useful for testing the two stronger conjectures.

## Small-case calculations

For a proposed lossless map from an `(n+1)`-state bulk to an `n`-state boundary:

| `n` | bulk states | boundary states | injective encoding possible? |
|---:|---:|---:|:---|
| 0 | 1 | 0 | no |
| 1 | 2 | 1 | no |
| 2 | 3 | 2 | no |
| 3 | 4 | 3 | no |
| 4 | 5 | 4 | no |
| 5 | 6 | 5 | no |

The Lean theorem `no_lossless_codimension_one_encoding` proves the entire family, not just these samples.

For proof traces, boundary dualization maps each state pointwise. Sample lengths are therefore:

| bulk trace length | boundary trace length | strict reduction? |
|---:|---:|:---|
| 0 | 0 | no |
| 1 | 1 | no |
| 2 | 2 | no |
| 5 | 5 | no |
| 10 | 10 | no |

The Lean theorem `dualTrace_length` proves this for every trace, while `strict_shortening_false` turns every nonempty trace into a counterexample to universal strict shortening.

## OEIS search

No OEIS search is applicable: the tested sequences are the elementary cardinality pairs `(n+1,n)` and the identity length sequence `0,1,2,3,…`; no enumerative conjecture is being inferred from them.

## Counterexample hunt

The smallest cardinality counterexample is a two-state bulk and one-state boundary. Any map identifies the two bulk states, so exact reconstruction is impossible. This is formalized by `bit_not_reconstructible_from_unit_boundary`.

The smallest strict-shortening counterexample is any singleton proof trace: its dual also has length one. The general Lean theorem covers all nonempty traces.

## Conclusion

Small cases immediately reject both unqualified strengthening attempts. They support focusing the positive theorem on semantic fixed-point duality and requiring extra structure for either dimensional compression or shorter proofs.
