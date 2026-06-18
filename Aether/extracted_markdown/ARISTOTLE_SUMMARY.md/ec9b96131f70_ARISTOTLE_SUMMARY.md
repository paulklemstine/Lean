# Summary of changes for run ae1bdc1f-c828-40a0-91d0-cad8080681f8
## What I did

I worked on the Carmichael / Fibonacci primitive-divisor cluster (the concrete priority targets `CarmichaelComposite` and the Fibonacci gcd/primitive-divisor theory).

### 1. Repaired the broken build
- The package was missing `srcDir = "Catalog"` in `lakefile.toml`, so no module resolved. Restored it.
- The chain referenced a file `Shared/CarmichaelHelper.lean` that did not exist, so `Shared/CarmichaelProof.lean` and everything downstream (`CarmichaelComposite`, `FibPrimitive`, `CarmichaelPrimitiveDivisor`) failed with a bad-import error. I created the missing file.

### 2. New sorry-free theorems
- `Catalog/Shared/CarmichaelHelper.lean` (3 theorems): proves the **prime case of Carmichael's theorem** — for a prime index `n ≥ 13`, every prime factor of `F(n)` is a primitive prime divisor (`fib_primitive_divisor_prime`), plus `fib_one_lt`. This is the previously-missing dependency consumed by `CarmichaelComposite.fib_carmichael`.
- `Catalog/Speculative/AutoResearch/CarmichaelEntryPointStructure.lean` (7 theorems): a unifying "apparition ideal / localization" treatment extending the catalog's primitive-divisor theory. Key results: the pinning law `p ∣ F_m ↔ n ∣ m` (`dvd_fib_iff_index_dvd`), `apparition_set_eq` (`{m | p ∣ F_m} = n·ℕ`), additive closure (`apparition_closed_add`), the generator characterization (`isPrimitive_iff_generates`), the exact density law `= ⌊N/n⌋` (`apparition_count`), and a Carmichael bridge (`prime_index_has_primitive`).

All new theorems build cleanly and depend only on the standard axioms `propext, Classical.choice, Quot.sound`.

### 3. Required deliverables
- `-- !-- ... -- !--` proof-sketch comments and `Lab Notebook` blocks (Hypothesis / Result / Insight / Failure analysis) in both `.lean` files.
- `FUTURE_DIRECTIONS.md` with 5 falsifiable directions, each with a "key insight" and a "Why now?" justification.

### Honest status of the remaining `sorry`
One pre-existing `sorry` remains in `Catalog/Shared/CarmichaelProof.lean`: the **composite asymptotic case `n > 10000`** of `fib_carmichael_composite`. This is exactly Carmichael's primitive-divisor theorem in its hard regime; it is not available in Mathlib and is a substantial standalone formalization (it requires the primitive part `Φ_n = ∏_{d∣n} F_d^{μ(n/d)}` with growth/LTE bounds). An automated attempt confirmed it is not closable directly. I deliberately did not weaken the statement or introduce any axiom; instead I isolated it and laid out two concrete attack plans for it as Directions 1 and 2 in `FUTURE_DIRECTIONS.md`. The composite case for `13 ≤ n ≤ 10000` and the full prime case are proved.