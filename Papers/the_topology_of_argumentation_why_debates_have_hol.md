# Computational Evidence — The Topology of Argumentation

All numbers below were computed inside Lean 4 / Mathlib (an executable model of
finite argumentation frameworks over `Fin n`) and cross-checked against the
formal proofs in the accompanying `.lean` files. Nothing here is hand-waved:
the executable definitions mirror the ones that are proved about.

## Objects computed

For a finite framework `(A, R)`:

* `chi`  = (unreduced) Euler characteristic of the **conflict-free complex**
  `K(AF)` = `∑_{∅ ≠ s conflict-free} (-1)^(|s|-1)`.
* `#pref` = number of **preferred extensions** (maximal admissible sets).
* `|grnd|` = size of the **grounded extension** (least fixed point of the
  defense operator, computed by iterating `charF` from `∅`).
* `RHS`  = `#pref − |grnd|`, the right-hand side of the conjectured identity
  `chi = #pref − |grnd|`.

## Data table

| framework                       | chi | #pref | \|grnd\| | RHS = #pref − \|grnd\| | chi = RHS ? |
|---------------------------------|----:|------:|---------:|-----------------------:|:-----------:|
| no-attack, `Fin 1`              |  1  |   1   |    1     |          0             |   **no**    |
| no-attack, `Fin 2`              |  1  |   1   |    2     |         −1             |   **no**    |
| no-attack, `Fin 3`              |  1  |   1   |    3     |         −2             |   **no**    |
| self-attack `0→0`, `Fin 1`      |  0  |   1   |    0     |          1             |   **no**    |
| 2-cycle `0↔1`, `Fin 2`          |  2  |   2   |    0     |          2             |     yes     |
| 3-cycle `0→1→2→0`, `Fin 3`      |  3  |   1   |    0     |          1             |   **no**    |
| single attack `0→1`, `Fin 2`    |  2  |   1   |    1     |          0             |   **no**    |
| path `0→1→2`, `Fin 3`           |  2  |   1   |    2     |         −1             |   **no**    |
| isolated `0→1` in `Fin 3`       |  1  |   1   |    2     |         −1             |   **no**    |

## Counterexample hunt — conclusion

The conjectured identity `chi(K(AF)) = |preferred| − |grounded|` **fails on the
very first example** (a single, unattacked argument: `chi = 1`, but
`#pref − |grnd| = 1 − 1 = 0`). It fails on 8 of the 9 sampled frameworks; the
lone agreement (the 2-cycle) is a numerical coincidence. The failure is not an
edge case: the two sides are invariants of genuinely different character — `chi`
is a topological invariant of the conflict (independence) complex, while
`#pref − |grnd|` is an order-theoretic quantity of the admissibility lattice.

The single-argument counterexample is the one formalized as
`euler_semantics_conjecture_false` in `ArgumentationSimplicial.lean`.

## What *is* true (and formalized)

* The conflict-free sets are downward closed, so `K(AF)` genuinely **is** a
  simplicial complex (`conflictFreeComplex`). (Note: it is the *conflict-free
  sets*, not the *preferred extensions*, that form the complex; preferred
  extensions are maximal and not downward closed.)
* `chi(full simplex on a nonempty vertex set) = 1` (`eulerChar_powerset`): the
  no-attack framework is contractible, matching the `chi = 1` rows above.
* A vertex `{a}` is a face iff `a` does not attack itself
  (`singleton_mem_conflictFreeComplex`), matching `self-attack Fin 1` having
  `chi = 0` (its only vertex is a phantom).

## Remark on `chi` as a component/hole count

For the *complete conflict graph* (every pair attacks, e.g. the 2- and 3-cycles
here) `K(AF)` is a set of `n` isolated points, so `chi = n` counts the
"independent debate threads". For the *empty conflict graph* (no attacks)
`K(AF)` is one big contractible simplex, so `chi = 1`. Thus `chi` really does
measure the topology of the disagreement pattern — just not the semantic
quantity proposed in the informal conjecture.
