# Computational Evidence

## Small-case calculation

For the checked instance with state space `Bool`, seed `{false}`, and transition `x ↦ !x`, finite iteration gives:

| steps | reached state | cumulative reachable region |
|---:|:---:|:---|
| 0 | `false` | `{false}` |
| 1 | `true` | `{false, true}` |
| 2 | `false` | `{false, true}` |
| 3 | `true` | `{false, true}` |

The Lean theorem `bool_toggle_canonicalLaw` proves that the canonical self-simulating law is `Set.univ`. The general theorem `mem_canonicalLaw_iff_reachable` proves that this finite-orbit calculation is exactly the least-fixed-point semantics, rather than merely an observed pattern.

## OEIS search

No OEIS search is relevant: the example is a two-state periodic orbit, and the main result concerns invariant sets and fixed points rather than a novel integer sequence.

## Counterexample hunt

The unrestricted claim that a simulator's fixed point is unique fails even on `Bool`: the identity monotone function has both `false` and `true` as fixed points. This motivated the corrected theorem, uniqueness of the *generated least invariant region*. The formal result does not claim arbitrary fixed-point uniqueness.

No computation supports a prediction of the fine-structure constant from the abstract fixed-point assumptions, so no such prediction is reported.
