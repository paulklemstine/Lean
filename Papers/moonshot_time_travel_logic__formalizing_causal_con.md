# Computational Evidence

The core objects are finite-state iterates, so exhaustive hand-sized calculations directly guided
the formal statements.

## Small cases: Boolean grandfather update

Let `G(false) = true` and `G(true) = false`.

| steps `n` | `G^[n](false)` | `G^[n](true)` | closed for every state? |
|---:|:---:|:---:|:---:|
| 0 | false | true | yes |
| 1 | true | false | no |
| 2 | false | true | yes |
| 3 | true | false | no |
| 4 | false | true | yes |
| 5 | true | false | no |
| 6 | false | true | yes |

This supports the exact parity classification proved in Lean: every even iterate returns to its
source, while no odd iterate does. The one-step fixed-point search checks both states and finds no
fixed point.

## Counterexample hunt

A tempting universal claim is “every closed deterministic causal loop has a fixed point.” Boolean
negation is a counterexample: its two-step orbit is closed, but neither Boolean state is fixed.
This counterexample motivated distinguishing `ClosedOrbit`, `NovikovConsistent`, and
`LoopHasFixedPoint`, and motivated the idempotence hypothesis in the separate collapse theorem.

For append-only branching histories, lengths were checked symbolically: appending one intervention
changes length from `n` to `n + 1`. Thus the resulting history cannot equal its source. Two sibling
branches have equal length, and a prefix relation between equal-length lists forces equality; if
their final interventions differ, neither can prefix the other.

## OEIS and plots

No nontrivial integer sequence arises. Orbit closure is simply the period-two pattern `0,1,0,1,…`,
so an OEIS search would add no useful evidence. No plot is informative beyond the parity table.
All claims retained from this exploration are proved in `Speculative/TimeTravelLogic.lean`.
