# Summary of changes for run de540ebd-cbee-41d3-a5b4-bc693d06fae9
## What was done

I investigated the requested `sorry`-fill target (`Applications/BoltzmannBridge/InterleavingRepresentation.lean`, which turned out to already be complete) and traced the project's only genuine code `sorry` to the Carmichael primitive-divisor development. Along the way I found the build itself was broken (missing `srcDir`, two missing modules, and a malformed comment). I fixed the infrastructure and contributed new, fully-proved mathematics.

### New `sorry`-free theorems (main results)

**`Catalog/Shared/CarmichaelHelper.lean`** (new) — the prime-index case of Carmichael's theorem:
- `fib_primitive_divisor_prime`: for prime `n ≥ 13`, every prime factor of `F n` is automatically a primitive prime divisor (purely order-theoretic, via `gcd(F m,F n)=F(gcd m n)`).

**`Catalog/Shared/CarmichaelObstruction.lean`** (new) — the headline contribution, the *complete local-to-global obstruction biconditional*:
- `one_lt_primPart_iff_hasPrimitive`: `1 < primPart n ↔ F n has a primitive prime divisor` (for `n ≥ 3`).
- Supporting: `stripAllAux_keeps_coprime_factor`, `primPart_keeps_primitive`, `hasPrimitive_imp_one_lt_primPart`.

The catalog previously had only the *sufficiency* direction (`1 < primPart n → …`). I proved the converse, giving the exact, decidable characterization: the computable primitive part detects primitivity faithfully. This shows the existing `native_decide` censuses are not merely sufficient but *characteristic*, and reduces all of Carmichael's theorem to a single arithmetic inequality. All results were checked to depend only on `propext`, `Classical.choice`, `Quot.sound` (no `sorryAx`).

Each new file contains a Lab Notebook block (Hypothesis / Result / Insight / Failure) and `-- !--` proof sketches as required.

### Build repair
- Added `srcDir = "Catalog"` to `lakefile.toml` (without it no module path resolved).
- Supplied the two missing modules `Shared.CarmichaelHelper` and `Shared.CarmichaelComposite` (the latter a re-export shim) so the historical Carmichael import chain elaborates again.
- Fixed an un-opened header comment in `Speculative/AutoResearch/FibPrimitive.lean`.

After these fixes the entire chain (`Shared.CarmichaelProof`, `Speculative.AutoResearch.CarmichaelComposite`, `Speculative.AutoResearch.FibPrimitive`, `Speculative.CarmichaelPrimitiveDivisor`, and my new files) builds with **exactly one** remaining `sorry`.

### The remaining open `sorry`
`Shared/CarmichaelProof.lean:fib_carmichael_composite` (composite `n > 10000`) is Carmichael's theorem proper. By the new biconditional it is equivalent to `primPart n > 1` for all large composite `n`, whose honest proof needs a cyclotomic lower bound on the homogeneous-cyclotomic factor `Φ_n(φ,ψ)` — machinery not present in Mathlib. Rather than introduce an axiom or a fake proof, I left it as a clearly-documented frontier and isolated exactly what it requires.

### FUTURE_DIRECTIONS.md
A narrative file with 5 falsifiable directions (each with a "key insight" and "Why now?"): closing the tail via the cyclotomic lower bound; generalizing the biconditional to arbitrary Lucas/strong-divisibility sequences; an effective quantitative bound `primPart n ≥ φ^{φ(n)/2}` (computationally testable); a presheaf/cohomological framing of the entry-point obstruction; and a multiplicativity conjecture on coprime indices.