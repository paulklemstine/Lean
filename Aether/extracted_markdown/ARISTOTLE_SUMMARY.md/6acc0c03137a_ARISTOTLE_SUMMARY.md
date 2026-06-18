# Summary of changes for run eb3330bd-bae7-4ca6-9c2b-6a391f4f9af8
Created a new, self-contained number-theory file `Catalog/NumberTheory/KorseltCarmichaelBridge.lean` (namespace `NumberTheory.KorseltBridge`) that completes the Korselt/Carmichael bridge. The earlier mixed-topic file `Catalog/afb009d7_retry3_aristotle/Bridges/KorseltUnitsBridge.lean` was left untouched and ignored.

Key finding about the requested API: Mathlib does provide the Carmichael (reduced totient) function as `ArithmeticFunction.Carmichael` (notation `λ`), but it does NOT define a Carmichael-number predicate `Nat.Carmichael`, nor a catalog theorem `korselt_iff_absFermatPsp` (these do not exist anywhere in the project or Mathlib). I therefore built the synthesis directly against the real `ArithmeticFunction.Carmichael` API, and — per the task's explicit fallback instruction — delivered the strongest clean theorem relating the three equivalent conditions instead of an iff with a nonexistent `Nat.Carmichael`.

Declarations proved (all fully, no `sorry`, only standard axioms):
- `prime_dvd_implies_sub_one_dvd_pred`: for prime `p ∣ n`, the universal unit-power hypothesis gives `(p-1) ∣ (n-1)` (via surjectivity of the unit reduction map and cyclicity of `(ZMod p)ˣ`).
- `carmichael_dvd_of_forall_units_pow`: forward implication `(∀ u, u^(n-1)=1) → λ n ∣ (n-1)` (using `carmichael_eq_exponent'` and `Monoid.exponent_dvd_of_forall_pow_eq_one`).
- `forall_units_pow_of_carmichael_dvd`: reverse implication, via `pow_carmichael`.
- `forall_units_pow_iff_carmichael_dvd`: the exponent-criterion bridge `(∀ u : (ZMod n)ˣ, u^(n-1)=1) ↔ λ n ∣ (n-1)` (proved in the clean generality needing only `NeZero n`).
- `carmichael_eq_primeFactors_lcm`: for odd squarefree `n`, `λ n = lcm_{p ∣ n} (p-1)` (via `carmichael_factorization`, squarefree multiplicity-one, and `carmichael_pow_of_prime_ne_two`/`totient_prime`).
- `korselt_dvd_iff_carmichael_dvd`: the local Korselt condition `∀ p prime, p∣n → (p-1)∣(n-1)` is equivalent to `λ n ∣ (n-1)` for odd squarefree `n`.
- `korselt_tfae`: the final synthesis for odd squarefree `n > 1`, showing the three conditions are equivalent — the group-theoretic exponent condition, the local Korselt divisibility condition, and `λ n ∣ (n-1)`.

The file is purely arithmetic/algebraic, imports only `Mathlib`, introduces no unrelated definitions, and contains no placeholders. It compiles cleanly; the main theorems were confirmed to depend only on `propext`, `Classical.choice`, and `Quot.sound`. (Note: the project's pre-existing `lakefile.toml` is misconfigured — its library globs point at root-level directories while the sources live under `Catalog/` — so the whole-project `lake build` was already broken before this work; the new file was verified directly with `lake env lean`.)