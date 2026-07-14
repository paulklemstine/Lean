# Computational Evidence — The Liar and Self-Referential Soundness

The central objects here are logical (impossibility of a self-referential soundness
predicate), so the "computational" evidence is a small, exhaustive truth-value
analysis rather than a numerical sequence. It is nonetheless decisive.

## 1. The Liar has no consistent truth value

Consider the equivalence forced by a Liar sentence `L` in a two-valued semantics
with `Truth (neg s) ↔ ¬ Truth s`:

    Truth L ↔ Truth (neg L) ↔ ¬ Truth L

Exhaustive check over the two possible values of `Truth L`:

| Truth L | ¬ Truth L | `Truth L ↔ ¬ Truth L` |
|:-------:|:---------:|:---------------------:|
|  true   |   false   |        false          |
|  false  |   true    |        false          |

Both rows are `false`: no assignment satisfies the equivalence. This is exactly
`not_iff_not_self` and underlies `no_self_negation` / `no_liar_via_negation`.

## 2. Tarski's collapse, made concrete

With an internal soundness/truth predicate `T` obeying `Truth (T s) ↔ Truth s`, the
diagonal sentence `L` satisfying `Truth L ↔ Truth (neg (T L))` reduces, by rewriting
with the two schemas, to `Truth L ↔ ¬ Truth L` — row-by-row impossible as above.
This is `tarski_undefinability`.

## 3. The hypotheses minus disquotation ARE satisfiable

To confirm the impossibility is *caused by the soundness predicate* and is not a
vacuous contradiction among the side conditions, take `S = Bool`,
`Truth b := (b = true)`, `neg := not`, `T := fun _ => false`:

- `neg_truth`: `not b = true ↔ ¬(b = true)` holds for both `b` (checked by `cases`).
- diagonal: `L = true` gives `Truth true ↔ Truth (neg (T true)) = Truth (not false) = Truth true`.
- `T_truth` fails: `Truth (T true) = (false = true) = false`, but `Truth true = true`.

So every ingredient except disquotation is realizable; the tangle is genuine. This
is the Lean lemma `tarski_hypotheses_satisfiable_without_truth_predicate`.

## 4. A concrete inhabited proof system

`exampleSystem` (`Sent := Prop`, `Prov := fun _ => False`, `Truth := id`) satisfies
every field of `ProofSystem`, including a Gödel sentence (`G := True`, since
`True ↔ ¬ False`). Hence `godel_true_unprovable` and `godel_incompleteness` are not
vacuous: e.g. `True` is true but unprovable in this system.

## Conclusion

The finite truth-value enumeration and the explicit `Bool`/`Prop` witnesses fully
corroborate the formal claims; no counterexample to the impossibility results exists,
by exhaustion of the two-element truth space.
