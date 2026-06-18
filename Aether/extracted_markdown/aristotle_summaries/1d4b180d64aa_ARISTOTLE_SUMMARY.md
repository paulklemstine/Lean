# Summary of changes for run de124465-3523-43b3-9ca2-2d5463b44976
## What was done

I delivered a new, fully-proved Lean file plus a research-directions document, building a **local-to-global / sheaf-theoretic** layer on top of the catalog's existing Fibonacci entry-point (rank-of-apparition) infrastructure.

### New Lean file: `Catalog/Pythagorean/FibEntryLocalGlobal.lean` (`sorry = 0`)
Four theorems, each proved and depending only on the standard axioms (`propext`, `Classical.choice`, `Quot.sound`):

1. `fib_divisibility_principal` — **stalk = principal ideal**: `{n | p ∣ F n} = {n | z(p) ∣ n}`. The entry point `z(p)` is a complete local invariant of the global divisibility section.
2. `fibEntry_eq_lcm_primePow` — **global gluing from prime-power charts**: for every `n > 0`, `z(n) = lcm_{p∣n} z(p^{v_p(n)})`. This strictly generalizes the catalog's `fibEntry_squarefree` from squarefree `n` to all `n`.
3. `fib_prod_dvd_iff_forall` — **local sections glue**: a pairwise-coprime product modulus divides `F n` iff each factor does.
4. `fibEntry_coprime_obstruction` — **overlap cocycle**: for coprime `m, n`, `z(m)·z(n) = z(m·n)·gcd(z(m), z(n))`, exhibiting the gcd as the exact obstruction to strict multiplicativity.

Each theorem includes a one-to-two-sentence proof sketch in `-- !-- ... -- !--` blocks, and the file carries a full Lab Notebook (Hypothesis / Result / Insight / Failure analysis). All results are built on and cite the catalog files `Catalog/Novelty/FibonacciEntryPointDuality.lean` and `Catalog/Novelty/FibCarmichaelStructure.lean`.

### `FUTURE_DIRECTIONS.md`
A narrative synthesis, a results summary table, and five falsifiable research directions (Wall–Sun–Sun prime-power law, the Carmichael infinite-tail via a cyclotomic lower bound, the gcd cocycle as a cohomological obstruction, reduction to squarefree radicals, and transfer to general Lucas sequences), each with a "The key insight is..." sentence and a "Why now?" justification.

### Build configuration
The project's `lakefile.toml` libraries used `srcDir = "."` with globs that matched no files under `Catalog/`, so catalog modules could not be built as targets. I added a single `Catalog` `lean_lib` (deliberately not in `defaultTargets`, so the many already-broken catalog files are not force-built) which lets the relevant modules and the new file compile via `lake build Catalog.Pythagorean.FibEntryLocalGlobal`. The new file builds cleanly.

### Note on the carried-over open `sorry`
The single genuine code `sorry` in `Catalog/Shared/CarmichaelProof.lean` is the *infinite tail* of Carmichael's primitive-divisor theorem (composite `n > 10000`). This requires analytic growth bounds on the primitive part of `F_n` versus the largest prime factor of `n` — not an entry-point lattice identity — so it is out of scope for this cycle and is documented as Direction 2 in `FUTURE_DIRECTIONS.md` with a concrete attack plan. (That file additionally imports a missing `Shared.CarmichaelHelper` module, which is why the new work was routed through the buildable `Catalog.Novelty.*` infrastructure instead.)