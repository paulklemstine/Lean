# Computational Evidence — The Modal Logic of Forcing

This file records the small-case checks that motivated
`MultiverseModalForcing.lean` before the formal proofs were written.

## 1. The forcing frame is an equivalence relation

We model a *world* as a truth assignment `α → Bool` on atomic assertions, and a
single *forcing step* as flipping one atom's truth value. The accessibility
relation `forcingRel` is the reflexive–transitive closure of single flips.

Since a flip is its own inverse (`flip (flip w a) a = w`), reachability by
flips is:

* **reflexive** (0 flips),
* **transitive** (compose flip sequences),
* **symmetric** (reverse the sequence).

Hence it is an *equivalence relation*, and its classes are exactly the sets of
worlds differing in finitely many atoms. On a finite atom set `α` with
`|α| = n`, every world reaches all `2^n` worlds, so each class has `2^n`
elements.

| n (atoms) | worlds `2^n` | reachable from any world |
|-----------|--------------|--------------------------|
| 1         | 2            | 2                        |
| 2         | 4            | 4                        |
| 3         | 8            | 8                        |

An equivalence relation is reflexive, transitive, **confluent** (directed) and
**Euclidean**; these are exactly the frame conditions that validate the modal
axioms `T`, `4`, `.2`, `5`. This is why the concrete forcing frame validates
`S4.2` (the Hamkins–Löwe modal logic of forcing) and in fact the stronger `S5`.

## 2. Frame condition ⇒ modal axiom (semantic check)

For a fixed relation `R` and world-predicate `P`:

| frame condition on `R` | modal principle proved            |
|------------------------|-----------------------------------|
| (any)                  | `K`: `□(p→q) → □p → □q`            |
| (any)                  | duality `◇p ↔ ¬□¬p`               |
| reflexive              | `T`: `□p → p`                     |
| transitive             | `4`: `□p → □□p`                   |
| confluent (directed)   | `.2`: `◇□p → □◇p`                 |
| Euclidean              | `5`: `◇p → □◇p`                   |

Each row is a theorem in the Lean file; the abstract lemmas are then
specialised to `forcingRel`.

## 3. Modal independence of an atom (e.g. CH)

Take the 3-atom model `{CH, VeqL, Meas}` and the Gödel world
`godel = (CH ↦ true, VeqL ↦ true, Meas ↦ false)`.

* Flipping `CH` from `godel` reaches a world with `CH = false`, so
  `◇¬CH` holds at `godel`.
* `godel` itself has `CH = true`, so `◇CH` holds at `godel`.

Therefore `CH` is *contingent* at `godel` (`◇CH ∧ ◇¬CH`), and since `◇CH` holds
from every world, `□◇CH` holds too. No counterexample exists: because the frame
is symmetric, *every* atom is contingent from *every* world. This matches the
set-theoretic fact that forcing settles no atomic independent statement.

## 4. Counterexample hunt

We searched for an atom and a world where forcing settles the atom (i.e.
`□(atom = true)` or `□(atom = false)` holds). None exists: `forcing_atom_not_nec`
proves `¬□(a = true)` at every world, and symmetrically for `false`. The
universal claim "every atom is contingent everywhere" survives.
