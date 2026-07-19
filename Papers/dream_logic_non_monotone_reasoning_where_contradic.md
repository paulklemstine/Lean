# Computational Evidence

## Small-case calculations

For one atom `a`, a signed belief state has four possibilities:

| Initial state | revise by `a+` | revise by `a−` |
|---|---|---|
| `∅` | `{a+}` | `{a−}` |
| `{a+}` | `{a+}` | `{a−}` |
| `{a−}` | `{a+}` | `{a−}` |
| `{a+, a−}` | `{a+}` | `{a−}` |

Thus revision selects the latest sign and retracts its contrary. In particular, the contradictory state is stable as information but is resolved by either revision.

For two atoms `a ≠ b`, the state `{a+, a−}` accepts a contradiction about `a` while omitting both `b+` and `b−`. This is the smallest non-explosive model: contradictory support does not force an unrelated assertion.

For finite-subset openness, the first partial unions of natural-number singleton states are:

| indices included | union | cardinality |
|---|---|---:|
| none | `∅` | 0 |
| `0` | `{0}` | 1 |
| `0,1` | `{0,1}` | 2 |
| `0,1,2` | `{0,1,2}` | 3 |
| `0,…,n−1` | `{0,…,n−1}` | `n` |

Every finite stage remains finitary, while the union over all indices is `ℕ` and is not finite.

## Counterexample hunt

The claim that finite subsets are the opens of an ordinary topology on an infinite type fails: the union of all singleton opens is the infinite whole space. The corrected structure is a **finitary topology**, requiring only finite unions. This distinction is reflected in the arbitrary-union obstruction theorem.

The non-explosion statement also needs a boundary condition. With only one atom, every positive literal belongs to the contradictory pair for that atom, so an “unrelated conclusion” requires a second, distinct atom.

## Sequence-database searches

No integer sequence is intrinsic to these structural claims, so an OEIS search is not applicable. LMFDB data likewise does not bear on signed-set revision or finite-union closure.

## Outcome

The finite computations support three formal targets: contradiction without explosion, non-monotone order-sensitive revision, and finite-but-not-arbitrary union closure. They also identify the exact guards needed to avoid false formulations.
