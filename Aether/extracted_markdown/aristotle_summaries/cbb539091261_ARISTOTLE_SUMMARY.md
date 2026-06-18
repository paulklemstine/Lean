# Summary of changes for run 911c156a-c684-4a14-a875-a6c1a43bc9c3
Completed the Korselt/Carmichael-lambda synthesis. Since the catalog files referenced in the brief (`Catalog/Shared/KorseltCriterion.lean`, `Catalog/Cryptography/KorseltGroupActionBridge.lean`, and the names `korselt_iff_absFermatPsp`, `Nat.carmichael`) do not actually exist in the project, I built a fully self-contained, sorry-free file `Catalog/afb009d7_retry3_aristotle/Bridges/KorseltCycleSynthesis.lean` (alongside the existing, untouched `KorseltUnitsBridge.lean`). It routes the whole equivalence through Mathlib's Carmichael lambda function `ArithmeticFunction.Carmichael` (the exponent of `(ZMod n)ˣ`).

Definitions:
- `IsKorselt n` — `Squarefree n ∧ ∀ prime p ∣ n, (p-1) ∣ (n-1)` (Korselt's criterion).
- `IsCarmichael n` — the absolute Fermat pseudoprime condition `∀ a : ZMod n, IsUnit a → a^(n-1) = 1`. As documented in the file, the compositeness requirement is intentionally omitted (per the brief's exact Task 3 signature) so the characterization holds verbatim; genuine Carmichael numbers are the composite numbers with this property.

Main results (all proved, depending only on `propext`, `Classical.choice`, `Quot.sound`):
- Task 1 `unit_pow_iff_isKorselt`: for squarefree `n`, `(∀ u : (ZMod n)ˣ, u^(n-1)=1) ↔ IsKorselt n`.
- Task 2 `carmichael_lambda_iff_isKorselt`: for squarefree `n`, `Carmichael n ∣ (n-1) ↔ IsKorselt n`.
- Task 3 `isCarmichael_iff_carmichael_lambda_dvd`: for squarefree `n`, `IsCarmichael n ↔ Carmichael n ∣ (n-1)`.

Key supporting lemmas: `forall_units_pow_iff_carmichael_dvd` (exponent characterization), `carmichael_prime` (`Carmichael p = p-1`), and `carmichael_squarefree` (`Carmichael n = lcm over p ∣ n of (p-1)`, via `carmichael_factorization` + `Finset.lcm_dvd_iff`).

Notes: The `Odd n` hypotheses (Tasks 2 & 3) and `Squarefree n` (Task 3) are not needed for the equivalences; they are kept to match the requested signatures and flagged as unused in the docstrings. The file compiles cleanly with `lake env lean` (only the expected unused-variable warnings for those kept hypotheses). The existing `KorseltUnitsBridge.lean` was preserved unchanged.