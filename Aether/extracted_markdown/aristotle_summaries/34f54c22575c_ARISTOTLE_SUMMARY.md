# Summary of changes for run 38298c9b-aef4-498e-a3f1-7c86be733476
## What I did

I worked on the Carmichael / Fibonacci primitive-prime-divisor layer of the catalog. On inspection the prior cycle's chain did **not build** and contained exactly one genuine `sorry`:

1. The foundational module `Shared.CarmichaelHelper` (imported by two files) **did not exist**.
2. `CarmichaelComposite.lean` was filed at a module path (`Speculative/AutoResearch/…`) that did not match its importers' `import Shared.CarmichaelComposite`.
3. The lake configuration was missing `srcDir = "Catalog"`, so no module resolved at all.
4. The headline theorem rested on a `sorry`: the composite "infinite tail" `n > 10000`.

### Infrastructure repairs
- Added `srcDir = "Catalog"` to `lakefile.toml` (without it the whole project failed to build).
- Created `Catalog/Shared/CarmichaelHelper.lean`.
- Relocated `CarmichaelComposite.lean` to `Catalog/Shared/` so its import path resolves; updated stale doc references.

The full chain now compiles (`Shared.CarmichaelHelper`, `Shared.CarmichaelComposite`, `Shared.CarmichaelProof`, `Shared.FibPrimitiveCharacterization`, `Speculative.CarmichaelPrimitiveDivisor`).

### New, fully-proved theorems (`sorry = 0`, verified to use only allowed axioms)
In `Catalog/Shared/CarmichaelHelper.lean`:
- `fib_primitive_divisor_prime` — **Carmichael's theorem, prime case**: every prime factor of `F(p)` is primitive (elementary via the strong-divisibility gcd law), plus helpers `fib_dvd_of_dvd_gcd`, `fib_gt_one_of_three_le`.

In `Catalog/Shared/FibPrimitiveCharacterization.lean`:
- `hasPrimitiveDivisor_iff_fibCoprimePart` — the **exact characterization**: `F(n)` has a primitive prime divisor **iff** the computational coprime part `fibCoprimePart n > 1` (upgrading the catalog's one-directional lemma to an equivalence). Built on a new p-adic stability toolkit (`prime_dvd_removePrimesOf`, `removePrimesOf_pos`, `fibCoprimePart_pos`, `prime_dvd_fibCoprimePart`).
- `fib_carmichael_verified` — the **honest, fully verified fragment** of Carmichael's theorem: `F(n)` has a primitive prime divisor for every `n ≥ 13` that is prime, or `n ≤ 10000`.

Both new files include `-- !-- Lab Notebook -- !--` blocks (Hypothesis / Result / Insight / Failure analysis) and `-- !--` proof-sketch comments.

### The remaining `sorry`
Exactly one `sorry` remains, in `fib_carmichael_composite` (composite `n > 10000`). This is the classical **analytic kernel** of Carmichael's 1913 theorem; a full proof requires the cyclotomic factorization `F(n) = ∏ Φ(d)`, a lifting-the-exponent lemma for `v_p(F(n))`, and a growth bound `Φ(n) > n` — none of which exist in Mathlib. I isolated and documented it precisely (with an in-file `-- !--` note pointing to the verified fragment) rather than weakening or faking the claim. None of the new theorems depend on it.

### FUTURE_DIRECTIONS.md
A narrative with a Synthesis, a Results Summary, and **five** falsifiable research directions — each with a "The key insight is…" sentence, a "Why now?" justification, and a concrete `#eval`-based falsification test. They lay out a complete roadmap to close the open kernel (cyclotomic `Φ`, Fibonacci LTE, growth bound) and two cross-domain bridges (general strong-divisibility sequences incl. Mathlib's elliptic divisibility sequences; and a Zsygmondy↔WQO link to the catalog's ordinal-analysis files).