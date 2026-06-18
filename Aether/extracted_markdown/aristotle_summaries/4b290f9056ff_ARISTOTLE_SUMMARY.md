# Summary of changes for run a6cdb107-2cf0-4a5f-848b-4e285423fc9a
Created a single self-contained file `Catalog/Bridges/KorseltExponentBridge.lean` proving the arithmetic bridge toward Korselt's criterion.

The theorem `ZMod.prime_sub_one_dvd_of_units_pow_eq_one` states: for `n p : ℕ` with `hp : p.Prime`, `hpn : p ∣ n`, `hn : n ≠ 0`, and `hpow : ∀ u : (ZMod n)ˣ, u ^ (n - 1) = 1`, we have `p - 1 ∣ n - 1`.

Proof strategy (as requested):
- Transports `hpow` along the existing surjective reduction homomorphism `ZMod.unitsMap : (ZMod n)ˣ →* (ZMod p)ˣ` (using `ZMod.unitsMap_surjective`) to show every unit `v : (ZMod p)ˣ` satisfies `v ^ (n - 1) = 1`.
- Concludes that `Monoid.exponent (ZMod p)ˣ ∣ n - 1` via `Monoid.exponent_dvd_of_forall_pow_eq_one`.
- Uses cyclicity of the unit group of the finite field `ZMod p` (`IsCyclic.exponent_eq_card`) together with `ZMod.card_units_eq_totient` and `Nat.totient_prime` to identify the exponent with `p - 1`.

No generator was chosen and no ad hoc cyclic-group infrastructure was developed; only existing Mathlib lemmas are used. The file consists of a module docstring, the documented theorem, and nothing else.

Verification: the file compiles cleanly (`lake env lean` succeeds), contains no `sorry`/`admit`, and the theorem depends only on the standard axioms `propext`, `Classical.choice`, `Quot.sound`.