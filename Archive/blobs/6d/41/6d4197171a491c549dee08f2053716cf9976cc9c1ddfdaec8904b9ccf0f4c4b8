# Summary of changes for run 2b5b60a9-d542-45e4-b3ff-dae3212fc664
Completed the Korselt/Carmichael arithmetic bridge as a self-contained, fully-proven file in the shared number-theory development.

What I did
- Added `Shared/KorseltCriterion.lean` containing the complete bridge pipeline with no `sorry` and no new axioms (both main theorems depend only on `propext`, `Classical.choice`, `Quot.sound`). It imports only `Mathlib`, so it compiles independently of unrelated pre-existing breakage elsewhere in the project.

The pipeline (clearly named lemmas):
1. `orderOf_dvd_of_pow_pred_eq_one` / `forall_orderOf_dvd_of_forall_pow_eq_one` — the group-theoretic bridge on `(ZMod n)ˣ`: `a ^ (n-1) = 1 → orderOf a ∣ (n-1)`, then the universal version over all units.
2. `exists_orderOf_eq_prime_sub_one` — finite-field structure: `(ZMod p)ˣ` is cyclic of cardinality `p-1` (via `IsCyclic.exists_ofOrder_eq_natCard` and `ZMod.card_units`), so it has an element of order exactly `p-1`.
3. `orderOf_dvd_of_dvd_modulus` — the minimal lift/reduce transfer: using surjectivity of the reduction homomorphism `ZMod.unitsMap : (ZMod n)ˣ →* (ZMod p)ˣ` (`ZMod.unitsMap_surjective`) and `orderOf_map_dvd`, the order bound transfers from modulus `n` to modulus `p`. No CRT decomposition is used.
4. `prime_sub_one_dvd_of_forall_pow_eq_one` — the core Korselt implication: for `n > 1` satisfying the universal Fermat unit condition and any prime `p ∣ n`, `(p-1) ∣ (n-1)`.
5. `korselt_squarefree` — the exact squarefree-form statement requested by the criterion; the proof shows the `Squarefree n` hypothesis is not actually needed for this direction, which is noted in its docstring (the hypothesis is kept only to match the classical phrasing).

Notes on the existing files
- The file `Shared/CarmichaelProof.lean` is about Fibonacci primitive prime divisors; its own `bridge_lemma` is already fully proven and is unrelated to Korselt's unit/order criterion (the `KorseltCarmichael.lean` file referenced in a docstring elsewhere does not exist in the project). I therefore delivered the requested Korselt bridge as the dedicated, reusable `Shared/KorseltCriterion.lean` rather than altering the unrelated Fibonacci proof. No user-provided content was deleted.

Verification: the file elaborates with no errors, contains no `sorry`, and the axiom check confirms only standard axioms are used.