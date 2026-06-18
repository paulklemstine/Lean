# Summary of changes for run f21a4d56-8953-4ea4-aef1-e3ec422d25d6
Added and fully proved the requested NumberTheory result in `Catalog/Bridges/NumberTheoryBridge.lean` (in the `NumberTheoryBridge` namespace), with no `sorry` and only standard axioms (`propext`, `Classical.choice`, `Quot.sound`).

Theorem `prime_sub_one_dvd_of_forall_units_pow_eq_one`: for naturals `n p`, if `Squarefree n`, `p.Prime`, `p ∣ n`, and `∀ u : (ZMod n)ˣ, u ^ (n - 1) = 1`, then `(p - 1) ∣ (n - 1)`.

Proof follows the intended strategy entirely within existing Mathlib algebra/number-theory API:
1. The hypothesis `p ∣ n` gives the induced units hom `ZMod.unitsMap : (ZMod n)ˣ →* (ZMod p)ˣ`, which is surjective (`ZMod.unitsMap_surjective`, using `NeZero n`).
2. Transporting `∀ u, u^(n-1)=1` across this surjection (via `map_pow`/`map_one`) yields `∀ v : (ZMod p)ˣ, v^(n-1)=1`.
3. Each such `v` then has `orderOf v ∣ (n-1)` (`orderOf_dvd_of_pow_eq_one`).
4. Since `(ZMod p)ˣ` is cyclic with `Nat.card = p-1` (`ZMod.card_units`), a generator from `IsCyclic.exists_ofOrder_eq_natCard` has order `p-1`, giving `(p-1) ∣ (n-1)`.

Notes:
- The informal target wrote the hypothesis as `Nat.Squarefree n`; the actual Mathlib predicate is `Squarefree n`, which is what is used. This is documented in the theorem's docstring.
- The squarefree hypothesis was kept as requested; it is used only to guarantee `n ≠ 0` (needed for surjectivity of the units map), and this is noted in the docstring.
- No topology/logic/HIT/pushout or other unrelated material was introduced; the change is confined to a single focused theorem with a short, robust proof.

Verification: the file elaborates with no errors under the project toolchain (`lake env lean` on the file), and an axiom check confirms only the standard axioms are used. (Note: the repository's top-level `lake` default-target layout has a pre-existing srcDir mismatch unrelated to this change, so per-file elaboration was used to verify.)