# Computational Evidence — Modal Forcing Structure of the Multiverse

The objects here are finite Boolean models (truth assignments to a finite set of
atomic assertions), so the relevant claims can be checked by direct enumeration.

## 1. Small-case branch counts

For `n` atomic assertions the full multiverse has `2^n` worlds:

| atoms `n` | worlds `2^n` |
|-----------|--------------|
| 1         | 2            |
| 2         | 4            |
| 3 (CH, V=L, Meas) | 8    |

The `n = 3` value `8` is confirmed by exhaustive count (`card_full_Claim`).

## 2. The Gödel–Cohen frame

Two explicit worlds over `{CH, V=L, Meas}`:

| world  | CH | V=L | Meas |
|--------|----|-----|------|
| Gödel  | T  | T   | F    |
| Cohen  | F  | F   | F    |

They differ on exactly two atoms, a finite amount of information, so they are
mutually accessible. Direct inspection confirms:

- `CH` is true at Gödel, false at Cohen → `CH` is a **switch** at Gödel.
- The law `V=L → CH` holds at both worlds → it is valid, hence settled.
- `CH` remains a switch after adopting that law (both worlds obey it yet
  disagree on `CH`).

## 3. Switch check for atoms

For any world `w` and atom `a`, the two updated worlds `w[a := true]` and
`w[a := false]` differ from `w` in at most one atom, so both are accessible, and
they realise `a` and `¬a` respectively. Enumerating all `2^3 = 8` worlds over
`{CH, V=L, Meas}` confirms every atom is possible and its negation is possible
from every world; hence no atom is necessary.

## 4. Frame conditions (checked by enumeration on small `n`)

The accessibility relation "agree outside a finite set" restricted to a fixed
finite atom set is the complete relation, which is reflexive, symmetric and
transitive. Exhaustive check for `n ≤ 3` confirms the `S5` frame conditions, in
agreement with the general proofs (`Reachable.rfl`, `Reachable.symm`,
`Reachable.trans`).

No counterexample to any stated claim was found in the exhaustive small-case
searches.
