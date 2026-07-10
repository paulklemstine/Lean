import Mathlib
import Applications.HypergraphRamsey.Defs

/-!
# Hypergraph Ramsey Theory: the Stepping-Up recursion (structural form)

The Erdős–Rado stepping-up recursion is the engine that pushes the r-uniform
Ramsey property up one level of uniformity at the cost of one exponential in the
ground set size:

  `HyperRamseyProp r N k k → HyperRamseyProp (r+1) (2^N) (k+1) (k+1)`.

Iterating this recursion is exactly what produces the tower-type upper bounds for
diagonal hypergraph Ramsey numbers (e.g. the double-exponential bound
`R₃(k,k) ≤ 2^{2^{ck}}`).

A complete formal proof of this recursion (the greedy Erdős–Rado nesting argument)
is a substantial development that is beyond the scope of the present files, so we
package the recursion as a named predicate, `SteppingUpProperty`, and thread it as
an explicit hypothesis through the tower-growth theorems in `TowerGrowth`.  Every
downstream theorem is therefore an honest *conditional* statement: it establishes
tower-type growth **given** the stepping-up recursion.  See `FUTURE_DIRECTIONS.md`
for the roadmap to discharging `SteppingUpProperty` unconditionally.
-/

open Finset Nat

/-- **The stepping-up recursion (structural form).**
`SteppingUpProperty` asserts that whenever the r-uniform Ramsey property holds on
`N` vertices for clique size `k` (with `1 ≤ r ≤ k`), the `(r+1)`-uniform Ramsey
property holds on `2^N` vertices for clique size `k+1`. This is the Erdős–Rado
upper-bound recursion behind the tower-type growth of hypergraph Ramsey numbers. -/
def SteppingUpProperty : Prop :=
  ∀ ⦃r k : ℕ⦄, 1 ≤ r → r ≤ k → ∀ N : ℕ,
    HyperRamseyProp r N k k → HyperRamseyProp (r + 1) (2 ^ N) (k + 1) (k + 1)