# Summary of changes for run 1d7bb8b0-d054-4172-9097-0ae058a63d3c
## Summary

I researched the Fibonacci **primitive-divisor (Carmichael) theorem** — the actionable core behind the cycle's priority targets (`CarmichaelComposite`, `Fib_gcd_identity`). The referenced `ordEGF` bridge does not exist in the catalog, and I found that the pre-existing Carmichael files (`Catalog/Shared/CarmichaelProof.lean`, `Catalog/Speculative/...`) are broken: they import a missing `Shared.CarmichaelHelper` and their main composite theorem still contains an unproven `sorry` for the deep asymptotic tail (`n` large), which is the genuinely hard part of Carmichael's 1913 result (Fibonacci Lifting-the-Exponent). Rather than ship anything with a `sorry`, I built a clean, self-contained, fully verified replacement.

### New file: `Catalog/Logic/FibonacciPrimitiveDivisorBounded.lean` (0 sorries, depends only on Mathlib)
Verified main results:
- **`fib_primitive_divisor_prime`** — *unconditional* proof that for every prime index `n ≥ 3`, every prime factor of `F(n)` is a primitive divisor (entry-point argument). Axioms: `propext, Classical.choice, Quot.sound`.
- **`fib_primitive_divisor_bounded`** — Carmichael's theorem fully proved on `13 ≤ n ≤ 10000`: `F(n)` has a primitive prime divisor. Combines the prime case with a verified GCD "strip the imprimitive part" certificate (`primPart`/`primPart_check` via reflection).
- **`fib_gcd_identity`** — the strong-divisibility identity `gcd(F m, F n) = F(gcd m n)` (the named priority target `Fib_gcd_identity`).
- **`fib_exceptional_no_primitive`** — sharpness: `F(n)` has *no* primitive prime divisor for `n ∈ {1,2,6,12}`, proving `13` is the sharp threshold.

All theorems compile cleanly (exit 0, no warnings) and use only permitted axioms (`native_decide` contributes `Lean.ofReduceBool`/`Lean.trustCompiler` to the bounded theorem only).

### Lab Notes
Inline `-- !-- Lab Notes -- !--` blocks document the hypotheses, the prime-vs-composite split rationale, failed unification attempt, and the `decide`-based sharpness method.

### `FUTURE_DIRECTIONS.md`
Five falsifiable, Lean-transcribable conjectures to close the unbounded tail and generalize: (1) Fibonacci Lifting-the-Exponent, (2) primitive-part dominance `Φ(n) > n`, (3) entry point divides `p − (5|p)`, (4) Lucas-number analogue, (5) multiplicity-one imprimitivity.

The pre-existing broken files were left untouched (their breakage predates this cycle).