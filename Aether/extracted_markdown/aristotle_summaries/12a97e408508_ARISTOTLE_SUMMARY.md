# Summary of changes for run f398f254-8fa9-40e1-bcc4-95e20bb60126
Produced a self-contained, sorry-free Lean 4 development plus a research roadmap, both placed under `Catalog/Speculative/AutoResearch/`.

**New Lean file: `Catalog/Speculative/AutoResearch/FibonacciEntryPointDuality.lean`** (imports only Mathlib, so it is independent of the catalog's currently-broken modules). It defines the Fibonacci entry point `fibEntry p` (rank of apparition) and proves four results:

1. `fib_dvd_iff_fibEntry_dvd` — the master duality `p ∣ F n ↔ z(p) ∣ n`, proved for *arbitrary* `p` (the primality hypothesis used by the prior one-directional catalog lemma turned out to be unnecessary).
2. `isFibPrimitiveDivisor_iff_entry` — a prime `p` is a primitive divisor of `F n` iff `z(p) = n`.
3. `fib_dvd_iff` — the strong-divisibility law `F m ∣ F n ↔ m ∣ n` for `m ≥ 3`, recovered as the special case `p = F m` of the duality.
4. `fib_primitive_divisor_verified` — a `native_decide` certificate of Carmichael's primitive-divisor theorem for `1 ≤ n ≤ 40`, `n ∉ {1,2,6,12}`, witnessed by an explicit table of least primitive prime divisors.

The whole development rests only on `Nat.fib_gcd` and `Nat.fib_dvd`. Each theorem carries a `-- !-- ... -- !--` proof sketch, and the file has a `-- !-- Lab Notebook -- !--` block (Hypothesis / Result / Insight / Failure analysis).

Verification: the module builds cleanly with zero `sorry` and no linter warnings; axiom check shows the three analytic theorems use only `propext, Classical.choice, Quot.sound`, and the finite certificate additionally uses the permitted `Lean.ofReduceBool, Lean.trustCompiler`.

**`Catalog/Speculative/AutoResearch/FUTURE_DIRECTIONS.md`** — narrative synthesis, a results-summary table, and five falsifiable research directions (primitive-part lower bound, lifting-the-exponent valuation identity, eventual surjectivity of the entry-point map, a chain complex from the entry-point lattice, and a `native_decide`-free verified algorithm), each with a "The key insight is…" sentence and a "Why now?" justification.

Build-config fix: the package's `lakefile.toml` was missing `srcDir = "Catalog"`, so module names (e.g. `Speculative.AutoResearch.…`) did not resolve and the project could not build at all; I added that one line, which makes the catalog's own module paths resolve and lets the new file build.