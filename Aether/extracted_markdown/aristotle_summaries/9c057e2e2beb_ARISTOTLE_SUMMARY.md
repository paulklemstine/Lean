# Summary of changes for run a2d23723-1c04-4813-9796-702fc02849d2
Created `Catalog/Algebra/CommSimpleGroup.lean` (106 lines, within the 80–200 line bound) containing exactly the requested two definitions and four theorems, all with complete tactic proofs (no `sorry`):

- `IsMinimalNormal` — normal, nontrivial, and minimal among normal nontrivial subgroups.
- `primeOrderSupport G` — the prime divisors of `Fintype.card G` as a `Finset ℕ` (via `Nat.primeFactors`).
- `eq_top_of_normal_ne_bot` (Thm 1) — in a simple group every nontrivial normal subgroup is `⊤`.
- `isMinimalNormal_unique` (Thm 2) — the minimal normal subgroup of a simple group is unique (both equal `⊤`).
- `prime_card_of_commSimple` (Thm 3) — a finite commutative simple group has prime cardinality.
- `primeOrderSupport_eq_but_card_ne` (Thm 4) — `Multiplicative (ZMod 2)` and `Multiplicative (ZMod 4)` have equal prime support (`{2}`) but different orders (2 ≠ 4).

The file builds successfully (`lake build Algebra.CommSimpleGroup`), contains no `sorry`, and the proofs use only the standard axioms (`propext`, `Classical.choice`, `Quot.sound`).

Note: the prompt's suggested import paths `Mathlib.GroupTheory.Subgroup.Basic` and `Mathlib.GroupTheory.SimpleGroup` do not exist in this project's Mathlib version (those modules were relocated), so the file uses a single `import Mathlib`, which covers all required content.