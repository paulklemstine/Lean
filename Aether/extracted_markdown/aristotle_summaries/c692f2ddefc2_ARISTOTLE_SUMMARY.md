# Summary of changes for run df7d6670-beb6-428d-9c12-1c8ba58ca5a9
## What was delivered

This v16b cycle produced three new artifacts (two Lean files + future directions), all building cleanly with only the standard axioms (`propext`, `Classical.choice`, `Quot.sound`) and **zero sorries**.

### 1. `Catalog/Shared/KorseltCriterion.lean` (Number theory)
Formalizes **Korselt's criterion** for Carmichael numbers and proves its constructive direction:
- `IsKorselt n` (squarefree + `(p-1) ∣ (n-1)` for all primes `p ∣ n`) and `IsFermatPsp n` (absolute Fermat pseudoprime).
- **Main theorem** `korselt_imp_fermatPsp`: if `n > 1` is Korselt then `a^(n-1) ≡ 1 [MOD n]` for every base coprime to `n`. The proof is the CRT decomposition argument: per-prime Fermat's little theorem (`pow_modEq_one_of_prime_factor`) reassembled via squarefreeness (`dvd_of_squarefree_forall_prime_dvd`).
- Worked, non-vacuous instance: `isKorselt_561` and `fermatPsp_561` for the smallest Carmichael number `561 = 3·11·17`.

### 2. `Catalog/Cryptography/KorseltGroupActionBridge.lean` (Cross-domain bridge)
The mandated Shared → Cryptography bridge via multiplicative-group order. It imports the Shared-domain result and combines it with the Cryptography `CryptoGroupAction`/`FreeTrans` framework:
- `korselt_units_pow_eq_one` / `korselt_orderOf_dvd`: lifts the ℕ congruence to `(ZMod n)ˣ`, showing every unit's order divides `n-1`.
- `korselt_action_pow_trivial`: in any `CryptoGroupAction` of `(ℤ/nℤ)ˣ`, the `(n-1)`-st power acts as the identity — the order-theoretic core of why a Fermat test fails on Carmichael numbers for every base.
- `korselt_freeTrans_recovers_order`: in a free torsor the order condition is recovered from the geometry of the action.
- `units_561_pow_eq_one`: non-vacuous instantiation at `561`.

Both files contain the required `-- !-- Lab Notes -- !--` blocks documenting the Hypothesize/Experiment/Analyze/Critique/Synthesize loop.

### 3. `FUTURE_DIRECTIONS.md`
Five falsifiable conjectures derived from the cycle (the iff converse of Korselt, generalized exponent form, order-spectrum density, geometric/torsor characterization, and cross-domain hardness transfer), each with a "The key insight is…" sentence and a "Why now?" justification.

### Notes on the existing catalog
- The originally-cited open `sorry` in `Catalog/Shared/CarmichaelProof.lean` is the composite tail of Carmichael's *Fibonacci primitive-divisor* theorem (`n > 10000`) — a hard classical result whose chain also depends on a `CarmichaelHelper` module that is absent from the project and on `Cryptography/CSIFiShAdvanced.lean`, which does not elaborate (its final section is truncated). These pre-existing files were left untouched (no content removed). The cross-domain group structure was therefore reproduced faithfully and self-containedly in the bridge file, with provenance documented in the Lab Notes.
- I added the missing `srcDir = "Catalog"` line to `lakefile.toml`. Without it none of the catalog modules were on the library source path (the globs referenced `Shared.+`, `Cryptography.+`, etc., but the sources live under `Catalog/`), so the project could not build any module. With this one-line fix the new modules build via `lake build Shared.KorseltCriterion Cryptography.KorseltGroupActionBridge`.