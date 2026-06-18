# Summary of changes for run d1ce2b6c-12be-4a33-896f-f68f3a062a4d
Created `KorseltUnitsBridge.lean` containing a single, fully-proved theorem `korselt_units_bridge`:

If `n` is squarefree, `p` is a prime dividing `n`, and every unit `u : (ZMod n)ˣ` satisfies `u ^ (n - 1) = 1`, then `(p - 1) ∣ (n - 1)`.

The proof follows the requested strategy exactly:
1. `orderOf_dvd_of_pow_eq_one` gives `orderOf u ∣ (n-1)` for every unit of `ZMod n`.
2. `ZMod.unitsMap_surjective` provides surjectivity of the reduction homomorphism `(ZMod n)ˣ →* (ZMod p)ˣ` (it needs only `p ∣ n` and `NeZero n`).
3. `IsCyclic.exists_ofOrder_eq_natCard` together with `ZMod.card_units` yields an element of order `p - 1` in `(ZMod p)ˣ`.
4. `orderOf_map_dvd` transports the divisibility through the surjection to all of `(ZMod p)ˣ`.
5. The order-`(p-1)` element then witnesses `(p - 1) ∣ (n - 1)`.

The file imports only `Mathlib`, contains no `sorry`, no unrelated content, and the proof is non-circular. It compiles successfully and `#print axioms` confirms it depends only on the standard axioms `propext`, `Classical.choice`, and `Quot.sound`. The `Squarefree n` hypothesis is kept as requested (it is documented in the docstring as not strictly necessary for this argument).