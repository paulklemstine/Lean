# Computational Evidence — No-Stretching of GF(2) Quotient Labelings

We test the claim `d_H(ℓ u, ℓ v) ≤ d_G(u, v)` on small connected graphs with explicit
edge partitions. Throughout, `ℓ` is the quotient labeling into `(ℤ/2)^t / cycleSpace`,
`gen i` is the image of the `i`-th coordinate direction, and `H` is the Cayley graph of
the quotient with connection set `{gen i}`.

## 1. The 4-cycle `C₄` with the two Djoković–Winkler classes (isometric case)

Vertices `0,1,2,3`; edges `01,12,23,30`. Partition into `t = 2` classes of opposite edges:
`A = {01, 23}`, `B = {12, 30}`.

* The only cycle traverses `A` twice and `B` twice ⇒ parity `(0,0)`, so `cycleSpace = {0}`,
  `rank A = 0`, quotient dimension `2 - 0 = 2`.
* Labels (root `0`): `0 ↦ (0,0)`, `1 ↦ (1,0)`, `2 ↦ (1,1)`, `3 ↦ (0,1)` — the four corners
  of the square `(ℤ/2)²`.
* Check: `d_G(0,2) = 2` and `d_H((0,0),(1,1)) = 2`. Equality holds everywhere; the labeling
  is an **isometric embedding** (a partial cube). No-stretching holds, with no slack.

## 2. The triangle `K₃` with three singleton classes (contraction appears)

Edges `e01, e12, e20` are classes `x, y, z` (`t = 3`).

* The 3-cycle has parity `(1,1,1)`, so `cycleSpace = span{(1,1,1)}`, `rank A = 1`, quotient
  dimension `3 - 1 = 2`.
* Labels (root `0`): `0 ↦ 0`, `1 ↦ (1,0,0)`, `2 ↦ (0,0,1)`.
* `d_G(1,2) = 1`; in the quotient `ℓ2 - ℓ1 = (1,0,1) ≡ (0,1,0) = gen y`, so
  `d_H(ℓ1, ℓ2) = 1`. Each edge still moves the label by one generator.
* All pairwise graph distances are `1`, all hypercube distances are `1`: no-stretching holds.

## 3. The 5-cycle `C₅` with a single class (maximal contraction)

All `5` edges share one class (`t = 1`). A closed walk of odd length (the 5-cycle itself) has
parity `(1)`, so `cycleSpace = (ℤ/2)¹` is the whole space, `rank A = 1`, quotient dimension
`1 - 1 = 0`.

* Every label is `0`, so `d_H(ℓ u, ℓ v) = 0` for all `u, v`, while `d_G` ranges over `{0,1,2}`.
* The inequality `0 ≤ d_G` holds trivially but **strictly** for distinct vertices: this is the
  pure-shortcut regime, the opposite extreme from case 1.

## Counterexample hunt

* **Wrong hypercube (refuted).** If one instead measures `d_H` in a *fixed basis* of the quotient
  (the standard hypercube), a single graph edge can flip several coordinates at once. In case 2,
  picking the basis `{(1,0,0),(0,1,0)}` of the quotient makes the increment for class `z` equal
  `(1,1)` (Hamming weight 2), so a one-step graph move would register hypercube distance 2 > 1.
  This confirms the Critic's note: the faithful `H` must use the *projected coordinate directions*
  `gen i`, not an arbitrary basis. The proved statement uses exactly these generators.
* No counterexample to the proved inequality was found across `C₄`, `K₃`, `C₅`, paths, and stars
  with assorted partitions; in every case each edge advances the label by one generator, which
  forces `d_H ≤ d_G` by subadditivity of the word metric.

## Summary table

| graph | `t` | `rank A` | quotient dim | regime |
|------|-----|----------|--------------|--------|
| `C₄` (2 DW classes) | 2 | 0 | 2 | isometric (equality) |
| `K₃` (3 classes) | 3 | 1 | 2 | tight, distance 1 |
| `C₅` (1 class) | 1 | 1 | 0 | total contraction |

The evidence is consistent with the theorem: the labeling never stretches, and the slack
`d_G - d_H` measures exactly the "shortcuts" created by the partition.
