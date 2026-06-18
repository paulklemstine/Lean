# Summary of changes for run 38372a85-28c5-4406-9600-dd4b14c65204
Delivered a new self-contained Lean development plus research notes for this cycle, building on the catalog's Fibonacci entry-point theory.

## New Lean file: `Catalog/Applications/FibonacciEntryPointCharacterization.lean`
Self-contained (`import Mathlib`), namespace `FibEntryChar`. All substantive results are proved with no `sorry` and depend only on the standard axioms `propext`, `Classical.choice`, `Quot.sound` (verified via `#print axioms`).

Proved results:
- `fib_dvd_gcd_of_dvd` — `p ∣ F n ∧ p ∣ F k → p ∣ F (gcd n k)` (gcd backbone, via `Nat.fib_gcd`).
- `fibEntryPt_pos`, `fib_dvd_fibEntryPt`, `fibEntryPt_min` — entry-point API (positivity, apparition, minimality).
- `fib_dvd_iff_entryPt_dvd` — **main theorem**: for any modulus with an entry point, `p ∣ F k ↔ α(p) ∣ k` for all `k`; i.e. the index set is the principal ideal `(α(p))`.
- `fib_dvd_setOf_eq_multiples` — set-level form `{k | p ∣ F k} = {k | α(p) ∣ k}`.
- `entryPt_eq_iff_primitive` — `p` is a primitive prime divisor of `F n` ↔ `α(p) = n`, recasting Carmichael's theorem as surjectivity of the entry-point map.
- `fib_twelve_no_primitive` — **boundary counterexample**: `F(12) = 144` has no primitive prime divisor, the exact structural reason Carmichael's theorem must exclude `n = 12`.

Left as an explicit conjecture (the only `sorry`, clearly marked as a research target): `fibEntryPt_mul_coprime`, the lcm law `α(a·b) = lcm(α a, α b)` for coprime `a, b`.

The file includes Step-1 theorem declarations, per-theorem Lab Notebook blocks (`-- !-- ... -- !--`) with Hypothesis/Result/Insight/Failure analysis, and a catalog-synthesis section citing the related catalog lemmas (`fibEntryPt`, `primitive_of_entryPt_eq` in `Speculative/AutoResearch/CarmichaelComposite.lean`, `bridge_lemma` in `Shared/CarmichaelProof.lean`).

## `FUTURE_DIRECTIONS.md`
Contains the required `## Synthesis` and `## Results Summary` sections plus 5 falsifiable research directions (lcm law, Carmichael-as-surjectivity, the growth bound for the infinite tail, the lifting-the-exponent step for prime powers, and generalization to Lucas sequences), each with Hypothesis / Test / Why now / If true / If false.

## Build setup
The real Lean root is the inner `Catalog/` directory. Its `lakefile.toml` (and the mirrored top-level copy) had no library covering the `Applications/` sources, so I registered a `lean_lib` named `Applications`. The new module builds cleanly with `lake build Applications.FibonacciEntryPointCharacterization`.

Note: pre-existing files `Shared/CarmichaelProof.lean` and `Speculative/AutoResearch/CarmichaelComposite.lean` reference a `Shared.CarmichaelHelper` module that is absent from the project and an undefined `fib_primitive_divisor_prime`, so those catalog files do not currently build; this was a pre-existing condition and is left untouched. My new development is independent of them and the related `sorry` (the composite infinite tail) is addressed analytically as Directions 3–4 in the notes.