# Summary of changes for run 5d5fced2-2572-40f1-9206-2c2aa8b8f3bf
## Phase A deliverables

### New Lean file: `Catalog/Speculative/AutoResearch/FibonacciEntryPointInvariant.lean`

This file promotes the project's Fibonacci-specific entry-point scaffolding (in `Catalog/Speculative/AutoResearch/FibonacciApparition.lean` and `CarmichaelComposite.lean`) into a **fully abstract theory of strong divisibility sequences**, parameterised only by the renormalization identity `gcd (u m) (u n) = u (gcd m n)`. It builds cleanly (verified with the build system) and is completely `sorry`-free; the main results depend only on the standard axioms `propext`, `Classical.choice`, `Quot.sound` (no `native_decide`, no `decide`).

**Theorem declarations and status (all `proved`):**
1. `StrongDivSeq.entry_dvd` — the rank of apparition divides every index of appearance; needs only the gcd identity and minimality of `Nat.find` (no primality, no closed form). Key insight: pull `m ∣ u n` and `m ∣ u e` into `m ∣ u (gcd n e)` and use minimality.
2. `StrongDivSeq.entry_eq_of_primitive` — a primitive divisor pins the entry point.
3. `StrongDivSeq.primitive_divisor_inj` — **(main)** "fractal injectivity": a fixed modulus is a primitive divisor of at most one index. Key insight: both indices equal the single value `entry u m`.
4. `StrongDivSeq.primitive_divisor_distinct` — distinct indices have disjoint primitive-divisor sets.
5. `fib_primitive_divisor_inj` and `mersenne_primitive_divisor_inj` — zero-cost instantiations of the abstract theorem at `u = Nat.fib` (via `Nat.fib_gcd`) and at the base-`a` Mersenne/repunit sequence `u n = a^n − 1` (via `Nat.pow_sub_one_gcd_pow_sub_one`), demonstrating cross-domain reuse.
6. `fibEntry_mul_coprime` — **multiplicativity of the Fibonacci rank of apparition on coprime moduli**: `fibEntry (a*b) = lcm (fibEntry a) (fibEntry b)` for coprime `a,b > 0`. This was an open conjecture in the input concept (its Direction 2); proved here via the law of apparition, exhibiting `fibEntry` as a lattice morphism dual to the `gcd ↦ gcd` half. (Supporting lemmas `Nat.eq_of_dvd_iff`, `coprime_mul_dvd_iff` are also fully proved.)

Each theorem carries a brief `-- !-- ... -- !--` proof sketch as requested.

### `FUTURE_DIRECTIONS.md`
A freeform narrative with five testable, falsifiable research directions extending the work (abstract multiplicativity + prime-power lifting-the-exponent; totality of the entry map as a hypothesis; a Mathlib-native Pisano period from the reversible pair-map; density of indices carrying a primitive divisor; and export to elliptic divisibility sequences). Each includes an explicit "The key insight is..." sentence and a "Why now?" justification.

### Build note
The project's `lakefile.toml` was missing the package `srcDir = "Catalog"` setting, so no catalog module could be located by `lake build` (modules are imported as e.g. `Shared.CarmichaelProof` but the sources live under `Catalog/`). I added that one line; this is an additive fix that makes the existing catalog and the new file build correctly, and changes no existing source content.