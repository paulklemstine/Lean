# Computational Evidence — Multiverse Set Theory

## Framework

We model Hamkins' *set-theoretic multiverse* abstractly, isolating exactly the
combinatorial content of the independence phenomena (CH true in some universes,
false in others; the "generic multiverse" closed under forcing) while remaining
fully formalizable in Lean/Mathlib.

- A **world** (model of ZFC) is a truth assignment `α → Bool` on a type `α` of
  atomic set-theoretic assertions (e.g. `CH`, `V=L`, "a measurable cardinal exists").
- A **sentence** is a propositional combination of atoms.
- A **multiverse** is a collection of worlds `Set (α → Bool)`.
- A sentence is **independent** in a multiverse iff some world satisfies it and
  some world refutes it.
- **Forcing** is modeled by the `flip` operation: from a world `w`, `flip w a`
  toggles the truth value of atom `a`, giving a "generic extension" that decides
  `a` the other way. A multiverse is **forcing-closed** if it is stable under all
  such flips (an abstraction of Hamkins' multiverse axioms).

## Small-case calculations

Number of worlds over `n` atomic sentences (worlds = `α → Bool`):

| n atoms | # worlds `2^n` |
|--------|----------------|
| 1      | 2              |
| 2      | 4              |
| 3      | 8              |
| 4      | 16             |

For the concrete instance with atoms `{CH, V=L, Meas}` we use two named worlds:

| world  | CH | V=L | Meas |
|--------|----|-----|------|
| Gödel (constructible universe `L`) | true | true | false |
| Cohen (a forcing extension)        | false| false| false|

In the two-world multiverse `{Gödel, Cohen}`, `CH` evaluates to `true` in Gödel
and `false` in Cohen, hence is **independent** — the core Hamkins observation.

## Key structural facts checked

- `Fintype.card (α → Bool) = 2 ^ Fintype.card α` (checked in Lean by `simp`).
- In the *full* multiverse (`Set.univ`), every atom is independent: the constant
  worlds `fun _ => true` and `fun _ => false` witness both truth values.
- The full multiverse is forcing-closed (`flip w a ∈ Set.univ` trivially).
- After imposing the law `V=L → CH` (restricting to worlds satisfying it), `CH`
  is **still** independent: both Gödel and Cohen satisfy the implication, yet
  disagree on `CH`. This mirrors that provable implications are shared across the
  multiverse while `CH` itself is not settled.

## Counterexample hunt

We tested whether independence could ever coexist with validity: it cannot, and
`Independent.not_valid` / `Valid.not_independent` are proved. We also confirmed
that logical validities (`p ∨ ¬p`, `¬(p ∧ ¬p)`, `p → p`) hold in *every* multiverse
(including the empty one) — i.e. first-order logical truth is absolute across
branches, in contrast to `CH`.

No counterexamples to the stated theorems were found; all are proved in Lean.

## OEIS

The world-count sequence `2^n` (1, 2, 4, 8, 16, ...) is
[OEIS A000079](https://oeis.org/A000079). No deeper sequence is central here.
