# Computational Evidence

## Small-case calculation

The test formula is

\[(x_0 \lor x_1 \lor \neg x_2) \land (\neg x_0 \lor x_2).\]

A concrete satisfying assignment is `x₀ = false`, `x₁ = true`, `x₂ = false`. The first clause is witnessed by `x₁`; the second is witnessed by `¬x₀`. The corresponding assembly recipe uses the same assignment. With three variables and two clauses, the construction has

\[2\cdot 3 + 2 + 2 = 10\]

pieces. These concrete facts are included as checked examples and an evaluated piece count in `JigsawSolutionSpace.lean`.

## OEIS search

No integer sequence is central to the claims. The results concern a general bijection between two finite witness sets rather than an experimentally inferred sequence, so no OEIS identifier is asserted.

## Counterexample hunt

Three boundary cases guided the statements:

| Case | Outcome | Consequence |
|---|---|---|
| Variables occurring outside the declared finite set | Their values would otherwise be uncontrolled | `extendAssignment` explicitly fixes them to `false` |
| A self-dual formula under global polarity reversal | Complementation need not give a free action within one solution space | Only transport between a formula and its complement is claimed |
| Abstract formula-indexed assembly versus physical rectangular placement | Abstract solvability omits rotations, locations, and collision constraints | No unrestricted geometric NP-completeness claim is made |

No counterexample exists to exact witness preservation in the stated model: the two directions use the same finite assignment and the established clause-level equivalence.

## Table of transported properties

| Property of the formula witness space | Property of the assembly-recipe space |
|---|---|
| Nonempty | Nonempty |
| Exact finite cardinality `k` | Exact finite cardinality `k` |
| Unique witness | Unique recipe |
| Solvable after global polarity reversal | Solvable after global tab–blank reversal |
