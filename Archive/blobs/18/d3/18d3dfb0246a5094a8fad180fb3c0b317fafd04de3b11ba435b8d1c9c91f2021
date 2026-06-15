# Summary of changes for run 27f312cc-aceb-44fc-90c7-69c5f8a2af4e
## What was delivered

**New Lean file** `Catalog/Speculative/AutoResearch/FibApparition.lean` — a self-contained extension of the Carmichael / Fibonacci primitive-divisor arc, building directly on the catalog's entry-point machinery (`Speculative.AutoResearch.CarmichaelHelper`) and the strong-divisibility identity `Nat.fib_gcd` (the catalog's `Fib_gcd_identity`). It contains **four theorems, all proved with `sorry = 0`** and depending only on the standard axioms (`propext`, `Classical.choice`, `Quot.sound`):

1. `fib_apparition_law` — the full **Fibonacci apparition law**: `p ∣ F(n) ↔ α(p) ∣ n`, identifying the entire zero-set of `n ↦ F(n) mod p` as the multiples of the rank of apparition. This upgrades the catalog's one-directional `entryPt_dvd` to a genuine equivalence.
2. `primitive_iff_entryPt_eq` — a divisor `p ∣ F(n)` is *primitive* iff `α(p) = n`, with **no primality hypothesis**, generalising the prime-only catalog result `fib_primitive_divisor_prime`.
3. `fib_dvd_fib_iff` — the **divisibility lattice**: for `m ≥ 3`, `F(m) ∣ F(n) ↔ m ∣ n`.
4. `fib_coprime_iff_gcd_le_two` — the coprimality dual: `gcd(F m, F n) = 1 ↔ gcd(m, n) ∈ {1, 2}`.

Each theorem carries a docstring, a `-- !-- … -- !--` proof-sketch block, and the file opens with a `-- !-- Lab Notebook -- !--` block (Hypothesis / Result / Insight / Failure analysis).

**`FUTURE_DIRECTIONS.md`** — a narrative synthesis plus five falsifiable research directions (closing the analytic infinite tail of the composite Carmichael case via the cyclotomic growth bound; lifting the apparition law to general Lucas/strong-divisibility sequences; the apparition map as a meet-complete lattice embedding; an effective `α(p) ∣ p − (5/p)` bound; and the sharp `{1,2,6,12}` exception list). Each includes a "The key insight is…" sentence and a "Why now?" justification.

**Infrastructure fixes (catalog now builds).** The project's `lakefile.toml` `srcDir` was set to `Catalog` so the file layout matches the library globs (previously nothing under `Catalog/` resolved). The arc's broken `import Shared.CarmichaelHelper` lines in `Catalog/Shared/CarmichaelProof.lean` and `Catalog/Speculative/AutoResearch/CarmichaelComposite.lean` were corrected to the real module `Speculative.AutoResearch.CarmichaelHelper`; with these fixes `Shared.CarmichaelProof` compiles.

**On the one remaining `sorry`.** The arc's single `sorry` is the infinite tail of `fib_carmichael_composite` (composite `n > 10000`). This is the genuinely hard analytic core of Carmichael's 1913 theorem — it cannot be discharged by finite computation and requires a cyclotomic lower bound rather than the entry-point bookkeeping the rest of the arc uses. Rather than claim a false fill, the new theorem `primitive_iff_entryPt_eq` reduces that goal to the clean estimate `primPart n > 1`, and Direction 1 of FUTURE_DIRECTIONS.md lays out the precise route to close it next cycle.

All new results were verified with `lake build` (clean, no warnings) and `#print axioms`.