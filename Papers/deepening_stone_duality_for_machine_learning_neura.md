# Computational Evidence — Stone Duality for Neural Networks

We model a `k`-neuron network by its **activation map** `act : X → P`, where the
pattern space `P = Fin k → Bool` collects all on/off firing patterns. The Stone
dual is the region map `S ↦ act⁻¹(S)` on the powerset Boolean algebra `Set P`.

## 1. Small-case calculations: number of patterns and regions

| neurons `k` | patterns `|P| = 2^k` | region-algebra size `2^(2^k)` |
|-------------|----------------------|--------------------------------|
| 0           | 1                    | 2                              |
| 1           | 2                    | 4                              |
| 2           | 4                    | 16                             |
| 3           | 8                    | 256                            |
| 4           | 16                   | 65536                          |

The number of patterns follows `card_neuralCode` (`2^k`); the number of distinct
regions of a network realizing all patterns is `Fintype.card (Set P) = 2^(2^k)`,
formalized as `card_regions`.

## 2. OEIS

* Patterns `2^k`: OEIS **A000079** (powers of two): 1, 2, 4, 8, 16, 32, …
* Region-algebra sizes `2^(2^k)`: OEIS **A001146**: 2, 4, 16, 256, 65536, … .

## 3. Counterexample hunt (duality faithfulness)

The claim "the Stone dual `region act` is injective" is **false in general** and
holds **iff** the network realizes every pattern (`act` surjective). Concretely,
take `k = 1` and a constant network `act x = (fun _ => true)`. Then only the
pattern `true` is realized, so `region act {false}` and `region act ∅` are both
`∅`, i.e. `region act` is not injective. This matches
`region_injective_iff_surjective`: injectivity ⇔ surjectivity of `act`. So the
"counterexample" is not a refutation but exactly the boundary the theorem draws.

## 4. Geometry sample (perceptron cells)

For a linear-threshold network `affineAct`, each neuron's "on" set is an open
affine half-space (`on_set_eq_halfspace`); a cell is the intersection over all
neurons of half-spaces, hence convex (`cell_convex`). Sampling random weight
matrices in dimension `n = 2` with `k = 3` neurons yields cells that are convex
polygons (bounded or unbounded), consistent with the theorem.

## Conclusion

The counting `2^(2^k)`, the injectivity boundary, and the convexity of cells are
all consistent with the small-case data, and are proved in
`StoneDualNeuralNetwork.lean`.
