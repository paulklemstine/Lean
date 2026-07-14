# Computational Evidence: the suspension tower of free ℤ₂-complexes

The combinatorial model represents `Sⁿ` as the boundary of the `(n+1)`-cross-polytope, with
vertices `SVert n = Fin (n+1) × Bool` (the signed unit vectors `±eᵢ`) and the free antipodal
action `anti (i,b) = (i,!b)`. A `ℤ₂`-map `Sᵐ → Sⁿ` is an equivariant simplicial map; by
`nonempty_iff_exists_pos` its existence is a **finite decidable** question (choose the images
of the `m+1` positive vertices, then check the no-antipodal-pair condition).

All checks below are discharged inside Lean by `decide` (kernel reduction), so they are not
merely scratch computations — they are the proofs used in `Z2SuspensionTower.lean`.

## 1. Small-case Borsuk–Ulam checks (`Nonempty (Z2Map m n)`?)

| domain `Sᵐ` | codomain `Sⁿ` | ℤ₂-map exists? | Lean fact |
|:-----------:|:-------------:|:--------------:|:----------|
| `S⁰` | `S⁰` | yes (identity) | `coindex_self 0` |
| `S¹` | `S⁰` | **no**  | `borsuk_ulam_S1_S0` (decide) |
| `S¹` | `S¹` | yes | `coindex_self 1` |
| `S²` | `S¹` | **no**  | `borsuk_ulam_S2_S1` (decide) |
| `S²` | `S²` | yes | `coindex_self 2` |
| `S³` | `S²` | **no**  | `borsuk_ulam_S3_S2` (decide, `maxRecDepth` raised) |

The pattern `Sⁿ⁺¹ ↛ Sⁿ` (no equivariant map lowers dimension) is the finite Borsuk–Ulam
theorem; verified here for `n = 0, 1, 2`.

## 2. The coindex sequence

Reading the table diagonally: the `ℤ₂`-coindex of `Sⁿ` is

    coind(Sⁿ) = n    (n = 0, 1, 2, ...)

confirmed exactly for `n ≤ 2` (lower bound `coindex_lower_bound`, upper bound the three
`decide` instances). This is OEIS **A001477** (the nonnegative integers `0,1,2,3,...`) — the
coindex simply reads off the dimension. The suspension tower shifts this sequence by its
height `k`: `coind(Sⁿ⁺ᵏ) ≥ coind(Sⁿ) + k`, and equality holds wherever the diagonal is sharp.

## 3. Counterexample hunt

* The universal claim proved is the *constructive* direction `m ≤ n → Nonempty (Z2Map m n)`
  (`coindex_lower_bound`) and the *descent* directions (5 in FUTURE_DIRECTIONS). No
  counterexample exists: `decide` over the finite reformulation confirms every base instance,
  and the descent lemmas are proved unconditionally.
* We specifically checked that the descent direction is the *only* valid one: there IS a map
  `S⁰ → Sⁿ` for all `n` (so "no map to a higher sphere" is false), matching
  `base_point_tower`. The genuine obstruction is only to *lowering* dimension.
* `decide` cost grows fast: `S³ ↛ S²` already requires `set_option maxRecDepth 100000`, which
  is why the general diagonal is left as the open Borsuk–Ulam/Tucker statement rather than
  brute-forced.

## 4. Summary table of the tower increment

| level `n` | `Nonempty (Z2Map n n)` | `IsEmpty (Z2Map (n+1) n)` | increment sharp? |
|:---------:|:----------------------:|:-------------------------:|:----------------:|
| 0 | yes | yes | ✔ |
| 1 | yes | yes | ✔ |
| 2 | yes | yes | ✔ |
| ≥3 | yes | open (needs full BU) | — |

This is exactly `tower_coindex_sharp` for `n ≤ 2`.
