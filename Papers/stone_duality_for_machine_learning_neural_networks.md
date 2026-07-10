# Computational Evidence: Stone Duality for Neural Networks

We model one fully-connected (ReLU-type) layer of `n` neurons evaluated on a finite input
sample `X`. Each input point `x` gets an **activation pattern** `act x : Fin n → Bool` recording
which neurons fire. The realized patterns are the **linear regions**; every subset `S` of
pattern-space selects a **decision region** `{x | act x ∈ S}`, and these form the Boolean algebra
`decisionAlgebra act`.

The central Stone-duality claim we verify is:

> `|decisionAlgebra act| = 2 ^ (number of linear regions)`.

## Small-case checks (in Lean, via `#eval`)

Take the sample `X = Fin 6` and the pattern map `g x = (fun i => decide (x % (i+2) = 0))`
(two "neurons"):

| quantity | value |
|---|---|
| `(image g univ).card` (linear regions) | 4 |
| `|decisionAlgebra g|` | 16 |
| `2 ^ 4` | 16 |

So `16 = 2^4`, matching the theorem `decisionAlgebra_card`.

Bounds also check out: with `n = 2` neurons on a sample of size `6`, the number of linear
regions is `4 ≤ min(2^2, 6) = 4` (`linearRegions_card_le_min`), and
`|decisionAlgebra| = 16 ≤ 2^6 = 64` (`decisionAlgebra_card_le`).

## Counterexample hunt for the *stated* VC-dimension conjecture

The mission text conjectures `VC dim = #linear regions`. This is **false** as a universal claim,
and no formal theorem asserts it. A single affine neuron on `ℝ^d` (a linear classifier) has VC
dimension `d + 1`, independent of the number of linear regions it induces on a sample (which is at
most `2`). What *is* true and provable is the pair we formalize instead:

* the decision algebra has exactly `2 ^ (#linear regions)` elements (Stone duality: atoms =
  linear regions); and
* shattering a sample of size `m` requires `m ≤ 2 ^ n` (`card_le_of_shatters`), a genuine
  VC-style capacity bound.

These are the honest, verified core of the Stone-duality picture; the naive equality
`VC = #regions` is recorded as refuted in `FUTURE_DIRECTIONS.md`.

## Why full real-arithmetic evidence is not needed

The Stone-duality content is combinatorial: it depends only on the activation-pattern map
`X → (Fin n → Bool)`, not on the specific real weights. The concrete `neuronActivation` /
`sampleActivation` constructions instantiate the map from real weights and biases, and all
abstract theorems specialize automatically (see `sampleActivation_decisionAlgebra_card`).
