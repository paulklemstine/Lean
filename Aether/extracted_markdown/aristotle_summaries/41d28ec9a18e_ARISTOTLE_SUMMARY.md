# Summary of changes for run ddb8f49d-f17e-4053-9d31-984f7344afff
## What was produced

**New Lean file:** `Catalog/Speculative/AutoResearch/FibonacciEntryPointDuality.lean` — a self-contained (`import Mathlib`), `sorry`-free development of the *rank of apparition* / entry point `z(p)` of the Fibonacci sequence, with 4 main theorems plus supporting lemmas. Every result was verified by elaboration against Mathlib, and `#print axioms` confirms each depends only on the allowed axioms (`propext`, `Classical.choice`, `Quot.sound`, plus `Lean.ofReduceBool`/`Lean.trustCompiler` for the `native_decide` certificate).

Main theorems (sorry = 0):
1. `fib_dvd_iff_fibEntry_dvd` — the master entry-point duality `p ∣ F_n ↔ z(p) ∣ n`, for every `p` admitting an entry point.
2. `isFibPrimitiveDivisor_iff_entry` — primitivity of `p` for `F_n` collapses to the single equation `z(p) = n`.
3. `fib_dvd_iff` — the strong-divisibility law `F_m ∣ F_n ↔ m ∣ n` (`m ≥ 3`), recovered as the specialization `p = F_m`.
4. `fib_primitive_divisor_verified` — a machine-checked (`native_decide`) instance of Carmichael's theorem: every `F_n`, `1 ≤ n ≤ 40`, `n ∉ {1,2,6,12}`, carries a primitive prime divisor.

Each theorem carries a `-- !-- ... -- !--` proof sketch, and the file opens with a `-- !-- Lab Notebook -- !--` block (Hypothesis / Result / Insight / Failure analysis).

**`FUTURE_DIRECTIONS.md`** — a narrative synthesis plus 5 falsifiable research directions (primitive-part lower bound; LTE collapse of the intrinsic prime; surjectivity of the entry-point map; a CSS chain complex from the divisor lattice; a `native_decide`-free verified primitive-divisor algorithm). Each includes a "The key insight is…" sentence and a "Why now?" justification.

## Catalog synthesis
The work unifies several scattered, one-directional catalog facts (`CarmichaelComposite.fibEntryPt_dvd_of_fib_dvd`, the `Algebra` LTE file's `fibEntryPoint`, and the computational primitive-part extractors `CarmichaelProof.primPart` / `CarmichaelComposite.fibCoprimePart`) as corollaries of a single biconditional, building on `Nat.fib_gcd` and `Nat.fib_dvd`.

## Note on the existing `sorry`
The catalog's only genuine remaining `sorry` is the infinite tail of Carmichael's composite case (`Shared/CarmichaelProof.lean`, `fib_carmichael_composite` for composite `n > 10000`). Its surrounding files also import a module (`Shared.CarmichaelHelper`) that is absent from the project, and the repository's top-level build configuration points its library globs at directories that do not exist — both pre-existing issues independent of this work. I left those files untouched and instead documented a concrete, reusable attack on that open tail in Directions 1–2 of `FUTURE_DIRECTIONS.md` (a uniform lower bound `Φ*(n) > n` plus the LTE valuation identity), which the new entry-point duality reduces to a single growth lemma.