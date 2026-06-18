# Summary of changes for run 100efa69-3dfa-4849-b4ea-844ec90218b7
## What was delivered

**New sorry-free Lean theory** — `Catalog/Novelty/FibonacciEntryPointClosure.lean`
A self-contained development of the *rank of apparition* (Fibonacci entry point) `α(m) = min { k>0 : m ∣ F(k) }`, proving 9 theorems with **zero `sorry`** (verified by build; axioms limited to `propext`, `Classical.choice`, `Quot.sound`):
- `fib_gcd_identity` — `gcd(F m, F n) = F(gcd m n)` (the requested "Fib gcd identity");
- `coprime_fib_of_coprime_index` — coprime indices ⇒ coprime Fibonacci values;
- `fibEntry_pos`, `dvd_fib_fibEntry`, `fibEntry_min` — structure of the entry point;
- `fibEntry_dvd_index` and `fib_dvd_iff_fibEntry_dvd` — the **apparition law** `m ∣ F(n) ↔ α(m) ∣ n`;
- `primitive_divisor_iff_fibEntry_eq` — the **main equivalence**: `m` is a primitive divisor of `F(n)` iff `α(m) = n`.

This isolates and generalizes (to an arbitrary modulus `m`, not just primes `p`) the algebraic core that the catalog's `Speculative.AutoResearch.CarmichaelComposite` and `Shared.CarmichaelProof` were reaching for, cleanly separating the *characterization* of primitivity (done here) from the *existence* of primitive divisors (the hard analytic tail). Each theorem carries a brief `-- !-- … -- !--` proof sketch, and the file contains a full Lab Notebook block (Hypothesis / Result / Insight / Failure analysis).

**`FUTURE_DIRECTIONS.md`** — synthesis, a results table, and 5 falsifiable research directions (each with a "key insight" and "why now"), including how to close the remaining catalog sorries.

**Build repairs** (the project did not build as received): added the required `srcDir = "Catalog"` and a missing `Novelty` library to `lakefile.toml`; fixed `Catalog/Speculative/PrimalityTesting/MillerRabin.lean` to import the real `Algebra.PrimalityTesting.Defs`; and removed a dangling import of the absent `Shared.CarmichaelHelper` from `Catalog/Shared/CarmichaelProof.lean`. After these fixes both modules elaborate (each still with its pre-existing sorry).

## On the three requested sorry-fills
The three placeholders are genuine research-level theorems: the `n > 10000` tail of Carmichael's Fibonacci primitive-divisor theorem (`fib_carmichael_composite`) and the Monier–Rabin `1/4` liar bound / witness existence (`miller_rabin_liar_card_le_quarter`, `exists_miller_rabin_witness`). High-effort attempts did not close them — they require Fibonacci growth/cyclotomic estimates and finite-group subgroup counting respectively. This is documented honestly in the Lab Notebook and FUTURE_DIRECTIONS.md (including the observation that the naive `φ(n) > (n−1)/4` route to the witness is *false* for primorial `n`). They were left as `sorry` (not weakened or axiomatized).