# Summary of changes for run 9b54bc18-65c7-4458-949d-174319f00205
Added a self-contained Lean development for the requested arithmetic step toward Korselt's criterion in `Catalog/Algebra/KorseltUnitsBridge.lean` (module `Algebra.KorseltUnitsBridge`, picked up by the existing `Algebra` library target).

The file contains exactly the requested pipeline, with all proofs complete:

1. `orderOf_dvd_of_forall_pow_eq_one` — if `g ^ m = 1` for every `g` in a monoid, then `orderOf g ∣ m`. The `[Finite G]` assumption from the suggested signature was unnecessary and omitted (`[Monoid G]` suffices), via `orderOf_dvd_of_pow_eq_one`.

2. `orderOf_map_dvd_of_surjective` — for a group hom `φ`, `orderOf (φ g) ∣ orderOf g`, proved directly from `(φ g) ^ orderOf g = 1`. The surjectivity hypothesis you specified is kept in the interface for faithfulness (documented in its docstring as not needed for this particular inequality).

3. Reduction map on units: rather than building a CRT decomposition by hand, the proof uses Mathlib's canonical `ZMod.unitsMap (hpn : p ∣ n) : (ZMod n)ˣ →* (ZMod p)ˣ` together with `ZMod.unitsMap_surjective` (which only needs `NeZero n`).

4. Main bridge `prime_sub_one_dvd_of_forall_units_pow_eq_one`: for squarefree `n`, prime `p ∣ n`, and `∀ u : (ZMod n)ˣ, u ^ (n-1) = 1`, concludes `(p-1) ∣ (n-1)`. It transports the kill-exponent along the surjection to `(ZMod p)ˣ`, then uses that `(ZMod p)ˣ` is cyclic of order `p-1` (`IsCyclic.exists_ofOrder_eq_natCard`, `ZMod.card_units`) to extract an element of order exactly `p-1`, whose order divides `n-1`.

Squarefreeness is used only to obtain `NeZero n` (noted in the module/theorem docstrings). The module docstring explains the arithmetic bridge, and there is no cryptography/pseudoprime/Carmichael material or any unrelated declarations.

Verification: `lake build Algebra.KorseltUnitsBridge` succeeds; the file contains no `sorry`; `#print axioms` on the main theorem shows only `propext`, `Classical.choice`, `Quot.sound`. (Note: a pre-existing, unrelated broken reference in the project, `Algebra/SumThreeCubes/Defs.lean`, prevents a full default-target build, so the new module was built explicitly.)