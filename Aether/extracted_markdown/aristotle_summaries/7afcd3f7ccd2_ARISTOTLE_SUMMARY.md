# Summary of changes for run b7161bb4-9519-46a3-a3cd-2f9b9ff421fa
Created a single, self-contained Lean file `Catalog/Algebra/PrimeSubOneDvdOfUnitsExponent.lean` containing exactly the requested theorem:

`prime_sub_one_dvd_of_forall_units_pow_eq_one {n p : ℕ} (hp : p.Prime) (hpn : p ∣ n) (hpow : ∀ u : (ZMod n)ˣ, u ^ (n - 1) = 1) : p - 1 ∣ n - 1`

The statement is verbatim what was specified (no weakening, no extra hypotheses). The proof follows the prescribed structure:
- Works only inside `(ZMod p)ˣ` and `(ZMod n)ˣ`.
- Uses cyclicity of `(ZMod p)ˣ` via `IsCyclic.exists_ofOrder_eq_natCard` to get a generator `g` with `orderOf g` equal to the group cardinality.
- Rewrites that cardinality as `p - 1` using `ZMod.card_units` (after `Nat.card_eq_fintype_card`).
- Lifts `g` along the surjective reduction homomorphism `ZMod.unitsMap hpn : (ZMod n)ˣ →* (ZMod p)ˣ` via `ZMod.unitsMap_surjective`.
- Transports `hpow u` through the homomorphism (`map_pow`/`map_one`) to get `g ^ (n - 1) = 1`, deduces `orderOf g ∣ n - 1` with `orderOf_dvd_of_pow_eq_one`, and substitutes `orderOf g = p - 1`.
- The degenerate `n = 0` case (where `NeZero n` would fail) is dispatched separately since `p - 1 ∣ 0` is immediate.

No additional helper lemmas were needed — the required units-reduction surjectivity already exists in Mathlib as `ZMod.unitsMap_surjective`. The file includes a concise module docstring explaining the theorem and the proof idea. It compiles with no errors and no unfinished declarations, and `#print axioms` confirms it depends only on `propext`, `Classical.choice`, and `Quot.sound`. No companion or experimental files were added.