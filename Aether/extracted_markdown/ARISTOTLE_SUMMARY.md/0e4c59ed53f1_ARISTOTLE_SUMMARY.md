# Summary of changes for run a5cb740e-d52b-4f24-82df-e1f50f806454
## Summary

I worked on the Fibonacci primitive-divisor ("Carmichael") theme. The Carmichael cluster was unbuildable on arrival: the module `Shared.CarmichaelHelper` (the prime-case dependency of `Shared/CarmichaelProof.lean` and `Speculative/AutoResearch/CarmichaelComposite.lean`) was missing entirely, and `Speculative/CarmichaelPrimitiveDivisor.lean` imported a mispathed module. I fixed the build and added new, fully verified theory.

### New files (both `sorry`-free, only standard axioms `propext`/`Classical.choice`/`Quot.sound`)

1. `Catalog/Shared/CarmichaelHelper.lean` — supplies the previously-missing dependency and proves, from first principles:
   - `Carmichael.dvd_fib_gcd`: the divisibility bridge `p ∣ F m → p ∣ F n → p ∣ F (gcd m n)`.
   - `Carmichael.isPrimitiveDivisor_iff_proper`: a prime factor of `F n` is primitive **iff** it avoids `F d` for every proper divisor `d ∣ n` (an infinite condition reduced to a finite one).
   - `Carmichael.exists_primitiveDivisor_of_prime`: **Carmichael's theorem for prime indices**, complete and unconditional — every prime `n ≥ 3` has a primitive divisor (in fact every prime factor of `F n` is primitive).
   - `fib_primitive_divisor_prime`: the packaged form the composite-case file consumes.

2. `Catalog/Shared/FibonacciRankApparition.lean` — the rank-of-apparition theory:
   - `dvd_fib_of_rank_dvd`, `rank_dvd_of_dvd_fib`, and their combination `dvd_fib_iff_rank_dvd` (the dictionary `p ∣ F n ↔ rank p ∣ n`).
   - `isPrimitiveDivisor_iff_rank_eq`: a prime factor of `F n` is primitive **iff** its rank of apparition equals `n` — recasting Carmichael's problem as "is `n` itself a prime's rank?".

Both files contain the requested `-- !-- Lab Notebook -- !--` blocks (Hypothesis / Result / Insight / Failure) and brief proof-sketch comments.

### Build fixes
- Added `srcDir = "Catalog"` to the root `lakefile.toml` so the package's modules resolve (previously no source module resolved from the root project).
- Corrected the broken import in `Catalog/Speculative/CarmichaelPrimitiveDivisor.lean` to point at `Speculative.AutoResearch.CarmichaelComposite`.
With these, the whole Carmichael chain now compiles except the single deep gap below.

### Remaining open `sorry` (documented, not filled)
The one `sorry` in `Catalog/Shared/CarmichaelProof.lean` is the **infinite tail** of Carmichael's theorem for composite `n > 10000`. This is the genuine analytic core of the theorem and requires a lifting-the-exponent law for Fibonacci numbers plus a Binet growth bound — infrastructure not present in Mathlib. I could not prove it honestly in this cycle, so I left it as `sorry` with an explanatory comment and made it the centerpiece of the future-work plan rather than fabricating a proof. The finite case (`13 ≤ n ≤ 10000`) was already discharged computationally upstream.

### `FUTURE_DIRECTIONS.md`
Five falsifiable directions, each with a "The key insight is…" sentence and a "Why now?" justification: (1) lifting-the-exponent for Fibonacci, (2) a two-sided Binet bound `F n ≥ φ^(n-2)`, (3) the integer-valued primitive part `Φ_n` via Möbius inversion, (4) coprimality/injectivity of primitive divisors across coprime indices (an immediate corollary of the new rank characterization), and (5) generalization to Lucas sequences / Zsygmondy. Directions 1–3 together would close the remaining `sorry`.

All new results were verified to be `sorry`-free with only the permitted axioms.