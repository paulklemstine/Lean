# Computational Evidence: Self-Quantifying Types and the Diagonal Gap

## 1. Small-case size gap `#T` vs `#(T → Prop)`

For finite `T`, the predicate space `T → Prop` behaves (constructively over a
two-element decidable value set) like `2^{#T}`, and the strict gap `#T < 2^{#T}`
is visible immediately:

| `#T` | `#T` | `2^{#T}` = candidate `#(T → Prop)` | gap |
|------|------|-------------------------------------|-----|
| 0    | 0    | 1                                   | ✓ 0 < 1 |
| 1    | 1    | 2                                   | ✓ 1 < 2 |
| 2    | 2    | 4                                   | ✓ 2 < 4 |
| 3    | 3    | 8                                   | ✓ 3 < 8 |
| 4    | 4    | 16                                  | ✓ 4 < 16 |

The gap `2^n - n` never vanishes for `n ≥ 0`; there is no `n` with `n = 2^n`.
This is the finite shadow of `selfquant_cardinal_strict` and already rules out any
finite self-quantifying type.

## 2. Fixed-point hunt for `Not` on `Prop`

We test the universal claim "no proposition equals its own negation" on the two
classical truth values:

| `P`    | `¬P`   | `¬P = P`? |
|--------|--------|-----------|
| True   | False  | no        |
| False  | True   | no        |

No fixed point exists, confirming `not_has_no_fixed_point`. This is the single
fact Lawvere's theorem converts into every impossibility in the file.

## 3. Counterexample hunt for the self-quantifying equivalence

We searched for any finite `T` admitting a bijection `T → (T → Prop)`. Since a
bijection requires `#T = #(T → Prop) = 2^{#T}`, and the table in §1 shows the two
sides never coincide, no finite counterexample exists. The Lean development
extends this to arbitrary types via `isEmpty_selfquant_equiv`.

## 4. Satisfiability of the self-referential system

The Gödel/Tarski results are stated over a `SelfRefSystem`. To confirm the
hypotheses are not contradictory (which would make the theorems vacuous), we
exhibit the concrete model `exampleSystem` (`Sentence = Bool`, truth = "= true",
nothing provable, `Definable φ := φ true`). All structure fields evaluate
correctly, so the theorems have genuine content. In that model negated truth is
indeed *not* definable, matching `tarski_truth_not_definable`.

## Conclusion

Every finite computation agrees with the general theorems: the size gap never
closes, negation has no fixed point, no self-quantifying bijection exists, and the
self-referential system is satisfiable. No counterexample was found.
