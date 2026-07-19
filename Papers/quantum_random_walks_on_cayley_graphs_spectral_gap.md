# Computational Evidence

The final result is a structural no-go theorem rather than an asymptotic estimate. Small cases illustrate the obstruction.

For the cyclic shift on `Z/nZ`, started at `0`, the distribution at time `t` is the point mass at `t mod n`:

| group | distributions over one period |
|---|---|
| `Z/2Z` | `(1,0)`, `(0,1)`, repeat |
| `Z/3Z` | `(1,0,0)`, `(0,1,0)`, `(0,0,1)`, repeat |
| `Z/4Z` | `(1,0,0,0)`, `(0,1,0,0)`, `(0,0,1,0)`, `(0,0,0,1)`, repeat |

None converges to uniform, although its Cesàro average over a whole period is uniform. This pattern is proved abstractly in `periodic_basisState_not_uniformly_mixing`, so the conclusion does not rely on unchecked numerical simulation.

No OEIS search is relevant: the proved connector concerns convergence of arbitrary periodic sequences, not a newly identified integer sequence.

Counterexample hunt: every finite cyclic shift with more than one state is a counterexample to universal pointwise mixing from a localized start. The Lean theorem proves the stronger statement for every positive finite-order evolution operator on every finite state space of cardinality greater than one.
