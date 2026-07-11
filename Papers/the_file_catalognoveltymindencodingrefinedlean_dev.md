# Computational Evidence — Graded Synapses and Merging Minds

Supporting evidence for the results in
`Catalog/Applications/MindEncodingWeightedMerging.lean`.

## 1. Graded description length `log₂(w^slots) = slots · log₂ w`

Small cases (`slots = C(N,2)`):

| N | slots | w=2 bits | w=3 bits (=slots·log₂3) | w=4 bits |
|---|-------|----------|--------------------------|----------|
| 3 | 3     | 3.000    | 4.755                    | 6.000    |
| 4 | 6     | 6.000    | 9.510                    | 12.000   |
| 5 | 10    | 10.000   | 15.850                   | 20.000   |

The Boolean (`w=2`) column is exactly `slots`, confirming `boolean_bits`.
For `w ≥ 3` the value strictly exceeds `slots` (confirming `weighted_bits_pos`);
for `w = 2` equality holds and for `w = 1` the cost is `0` (a single weight
level carries no information), which is the boundary case where the premium
vanishes.

## 2. Merge law `synapseSlots(∑Nᵢ) = ∑ synapseSlots Nᵢ + crossPairs`

Cross-check on `L = [3, 4, 5]` (total 12 neurons):

* `C(12,2) = 66` total slots.
* intrinsic `C(3,2)+C(4,2)+C(5,2) = 3+6+10 = 19`.
* cross `3·4 + 3·5 + 4·5 = 12+15+20 = 47`.
* `19 + 47 = 66`. ✓

Further samples (all verified by the identity):

| L            | ∑N | C(∑N,2) | intrinsic | crossPairs |
|--------------|----|---------|-----------|------------|
| [2,2]        | 4  | 6       | 2         | 4          |
| [1,1,1]      | 3  | 3       | 0         | 3          |
| [3,4,5]      | 12 | 66      | 19        | 47         |
| [10,10]      | 20 | 190     | 90        | 100        |

## 3. Square-of-a-sum identity `(∑Nᵢ)² = ∑Nᵢ² + 2·crossPairs`

On `[3,4,5]`: `12² = 144`, `∑Nᵢ² = 9+16+25 = 50`, `2·47 = 94`, and
`50 + 94 = 144`. ✓  This exposes the quadratic growth of the cross term.

## 4. Directed graded state space `w^(N(N-1)) = (w^slots)²`

`N=4, w=3`: `directedSlots 4 = 12`, `3^12 = 531441 = (3^6)² = 729²`. ✓

All numerical checks above are discharged inside the Lean file by `decide` on
concrete instances, so the tables are machine-confirmed, not merely tabulated.
